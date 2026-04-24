from flask import Flask, render_template, request
from flask_socketio import SocketIO, emit
import os
import time

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'secret!')
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='eventlet' if os.environ.get('RENDER') else 'threading')

# Store the latest screen state and connection status
phone_state = {
    "connected": False,
    "last_seen": 0,
    "current_app": "Home",
    "screen_data": None,
    "privacy_mode": False,
    "locked_device_id": None
}

# For Vercel/Serverless support
@app.route('/api/status')
def status():
    return phone_state

@app.route('/')
def index():
    return render_template('login.html')

@app.route('/dashboard')
def dashboard():
    return render_template('index.html')

@app.route('/phone')
def phone():
    return render_template('phone.html')

@socketio.on('verify_login')
def handle_login(data):
    global phone_state
    password = data.get('password')
    device_id = data.get('device_id')
    
    if password == 'saiwan123':
        # HWID Lock Disabled for now - allow any device with correct password
        emit('login_response', {'success': True, 'message': 'Logged In', 'device_id': device_id})
    else:
        emit('login_response', {'success': False, 'message': 'Invalid Password'})

@socketio.on('connect')
def handle_connect():
    print(f"Client connected: {request.sid}")

@socketio.on('phone_status')
def handle_phone_status(data):
    global phone_state
    phone_state["connected"] = data.get("connected", False)
    phone_state["last_seen"] = time.time()
    phone_state["current_app"] = data.get("current_app", "Home")
    phone_state["privacy_mode"] = data.get("privacy_mode", False)
    
    # Broadcast to all clients (the dashboard)
    emit('update_dashboard', phone_state, broadcast=True)

@socketio.on('screen_frame')
def handle_screen_frame(data):
    # This would receive base64 screen data from the phone
    # and relay it to the dashboard
    emit('new_frame', data, broadcast=True)

@app.route('/static/sw.js')
def sw():
    return app.send_static_file('sw.js')

if __name__ == '__main__':
    socketio.run(app, debug=True, port=5000, host='0.0.0.0')
