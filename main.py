from flask import Flask
from flask import flash
from flask import redirect
from flask import render_template
from flask import request
from flask import session
from flask import abort
from flask import url_for

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

####     FORMULARIO DE REGISTRO      ###

## FORMULARIO PARA CREAR USUARIO ##
@app.route('/registration_form')
def registration_form():
    return render_template('register.html')

## VALIDAR CAMPOS ##
@app.route('/register', methods=['POST'])
def register():

    tipo_usuario = request.form['tipo_usuario']
    username = request.form['username']
    email = request.form['email']
    telefono = request.form['telefono'] 
    
    password = request.form['password']
    password2 = request.form['password2']

    nombre = request.form['nombre']
    apellido_paterno = request.form['apellido_paterno']
    apellido_materno = request.form['apellido_materno']
    sexo = request.form['sexo']
    fecha_nacimiento = request.form['fecha_nacimiento']

    #Validar campos vacios
    if tipo_usuario == "1":
        if apellido_materno is None or apellido_materno is None:
            return render_template('register.html', mensaje="Algun campo está vacío" )
        if sexo is None or fecha_nacimiento is None:
            return render_template('register.html', mensaje="Algun campo está vacío" )       
    
    #Validar que las cont coincidan
    if password != password2:
        return render_template('register.html', mensaje="Las contraseñas no coinciden" )

    #Validar que no exisa usuario ni correo
    cursor = mydb.cursor()
    cursor.execute('SELECT username FROM Usuario WHERE UserName = "%s"' % username )
    result = cursor.fetchone()

    if result is not None:
        return render_template('register.html', mensaje="usuario existente" )

    cursor.execute('SELECT Email FROM Usuario WHERE Email = "%s"' % email)
    result = cursor.fetchone()

    if result is not None:
        return render_template('register.html', mensaje="correo existente")

    #REGISTRO DEL USUARIO#
    sentence = 'INSERT INTO Usuario(UserName,TipoUsuario,HashPassword,Email,Telefono,Admin) VALUES (%s,%s,%s,%s,%s,FALSE)'
    variables = (username,tipo_usuario,password,email,telefono)
    cursor.execute(sentence,variables)
    mydb.commit()
        
    #EXTRACCION DEL NUEVO ID#
    cursor.execute('SELECT idUsuario FROM Usuario WHERE UserName = "%s"' % username)
    result = cursor.fetchone()

    if tipo_usuario == "1":
        sentence = 'INSERT INTO Persona(Nombre,ApellidoPaterno,ApellidoMaterno,IdUsuario,Sexo,FechaNacimiento) VALUES (%s,%s,%s,%s,%s,%s)'
        variables = (nombre,apellido_paterno,apellido_materno,result[0],sexo,fecha_nacimiento)
    else:
        sentence = 'INSERT INTO Empresa(Nombre, IdUsuario) VALUES (%s,%s)'
        variables = (nombre,result[0])
        
    cursor.execute(sentence,variables)
    mydb.commit()
    session['logged_in'] = True
    return home()

## ELIMINAR ELIMINAR ELIMINAR
@app.route('/post')
def post():
    return render_template('post_home.html')

if __name__ == '__main__':
    app.secret_key = os.urandom(12)
    app.run(debug=True)
