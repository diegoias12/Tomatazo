from flask import Flask
from flask import flash
from flask import redirect
from flask import render_template
from flask import request
from flask import session
from flask import abort

from database import mydb

import os

app = Flask(__name__)

@app.route('/')
def home():
    if not session.get('logged_in'):
        return render_template('login.html')
    else:
        return render_template('home.html')

@app.route('/login', methods=['POST'])
def login():

    user_email = request.form['username']
    paswd = request.form['password']

    cursor = mydb.cursor()
    cursor.execute('SELECT HashPassword FROM Usuario WHERE UserName = "%s"' % user_email)
    result = cursor.fetchone()
    if result is None:
        return home()

    if paswd == result[0]:
        session['logged_in'] = True
    else:
        flash('Wrong password')
    return home()

@app.route('/logout')
def logout():
    session['logged_in'] = False
    return home()

@app.route('/profile')
def profile():
    return render_template('profile.html')

@app.route('/explore')
def explore():
    return render_template('explore.html')

if __name__ == '__main__':
    app.secret_key = os.urandom(12)
    app.run(debug=True)