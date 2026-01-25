from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from imap_tools import MailBox, AND
from datetime import datetime, timedelta
import re
import os

app = Flask(__name__)
CORS(app)

# Lưu trữ sessions
active_sessions = {}

@app.route('/')
def index():
    return send_file('index.html')

@app.route('/api/login', methods=['POST'])
def login():
    """Đăng nhập và test kết nối Gmail"""
    data = request.json
    email = data.get('email')
    password = data.get('password')
    
    if not email or not password:
        return jsonify({
            'success': False,
            'message': 'Vui lòng nhập đầy đủ email và App Password!'
        }), 400
    
    try:
        # Test kết nối
        with MailBox('imap.gmail.com').login(email, password) as mailbox:
            # Kết nối thành công
            session_id = str(datetime.now().timestamp())
            active_sessions[session_id] = {
                'email': email,
                'password': password,
                'created_at': datetime.now()
            }
            
            return jsonify({
                'success': True,
                'message': 'Đăng nhập thành công!',
                'sessionId': session_id
            })
            
    except Exception as e:
        error_msg = str(e)
        if 'AUTHENTICATIONFAILED' in error_msg or 'Invalid credentials' in error_msg:
            message = 'Email hoặc App Password không đúng!'
        elif 'Lookup failed' in error_msg:
            message = 'Không có kết nối internet!'
        else:
            message = f'Lỗi kết nối: {error_msg}'
        
        return jsonify({
            'success': False,
            'message': message
        }), 401

@app.route('/api/read-emails', methods=['POST'])
def read_emails():
    """Đọc email từ Gmail"""
    data = request.json
    session_id = data.get('sessionId')
    
    if not session_id or session_id not in active_sessions:
        return jsonify({
            'success': False,
            'message': 'Session không hợp lệ. Vui lòng đăng nhập lại!'
        }), 401
    
    session = active_sessions[session_id]
    email = session['email']
    password = session['password']
    
    try:
        emails_data = []
        
        with MailBox('imap.gmail.com').login(email, password) as mailbox:
            # Lấy 15 email mới nhất
            messages = list(mailbox.fetch(limit=15, reverse=True))
            
            for msg in messages:
                # Lấy nội dung email
                text_content = msg.text or ''
                html_content = msg.html or ''
                full_content = text_content + ' ' + html_content
                
                # Trích xuất mã (4-8 số)
                codes_6 = re.findall(r'\b\d{6}\b', full_content)
                codes_5 = re.findall(r'\b\d{5}\b', full_content)
                codes_4 = re.findall(r'\b\d{4}\b', full_content)
                codes_8 = re.findall(r'\b\d{8}\b', full_content)
                
                all_codes = list(set(codes_6 + codes_8 + codes_5 + codes_4))
                
                # Tìm từ khóa xác thực
                verification_keywords = [
                    'verification code', 'verification', 'verify',
                    'mã xác thực', 'mã xác nhận', 'xác thực',
                    'OTP', 'security code', 'confirmation code',
                    'access code', 'authentication code'
                ]
                
                has_keyword = any(
                    keyword.lower() in full_content.lower() 
                    for keyword in verification_keywords
                )
                
                # Lấy tên người gửi
                from_name = msg.from_ or 'Unknown'
                
                # Tạo snippet
                snippet = text_content[:200].replace('\n', ' ').strip() if text_content else ''
                
                email_data = {
                    'from': from_name,
                    'fromEmail': msg.from_,
                    'subject': msg.subject or '(No Subject)',
                    'date': msg.date.isoformat() if msg.date else datetime.now().isoformat(),
                    'snippet': snippet,
                    'mainCode': codes_6[0] if codes_6 else (codes_5[0] if codes_5 else (codes_4[0] if codes_4 else (codes_8[0] if codes_8 else None))),
                    'allCodes': all_codes[:5],
                    'hasVerificationKeyword': has_keyword,
                    'timestamp': int(msg.date.timestamp() * 1000) if msg.date else int(datetime.now().timestamp() * 1000),
                    'isVerificationEmail': has_keyword and len(all_codes) > 0
                }
                
                emails_data.append(email_data)
        
        # Sắp xếp theo thời gian mới nhất
        emails_data.sort(key=lambda x: x['timestamp'], reverse=True)
        
        return jsonify({
            'success': True,
            'emails': emails_data,
            'count': len(emails_data),
            'lastUpdate': datetime.now().strftime('%H:%M:%S')
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Lỗi đọc email: {str(e)}'
        }), 500

@app.route('/api/logout', methods=['POST'])
def logout():
    """Đăng xuất"""
    data = request.json
    session_id = data.get('sessionId')
    
    if session_id and session_id in active_sessions:
        del active_sessions[session_id]
    
    return jsonify({
        'success': True,
        'message': 'Đã đăng xuất!'
    })

def cleanup_old_sessions():
    """Xóa session cũ (> 1 giờ)"""
    now = datetime.now()
    expired_sessions = []
    
    for session_id, session in active_sessions.items():
        if now - session['created_at'] > timedelta(hours=1):
            expired_sessions.append(session_id)
    
    for session_id in expired_sessions:
        del active_sessions[session_id]

if __name__ == '__main__':
    print("""
╔════════════════════════════════════════╗
║  🚀 EMAIL VIEWER SERVER (PYTHON)       ║
╠════════════════════════════════════════╣
║  📡 Server: http://localhost:5000      ║
║  📧 Chế độ: User nhập credentials      ║
║  🔒 Bảo mật: Session-based             ║
║  🐍 Backend: Python + Flask            ║
╚════════════════════════════════════════╝
    """)
    
if __name__ == '__main__':
    import os
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)