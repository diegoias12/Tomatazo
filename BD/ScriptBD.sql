-- CREACION DE LA BASE DE DATOS --

#CREATE DATABASE Tomatazo;

USE Tomatazo;

-- CREACION DE LAS TABLAS --

DROP TABLE IF EXISTS Usuario;
CREATE TABLE IF NOT EXISTS Usuario (
	IdUsuario INT NOT NULL AUTO_INCREMENT COMMENT 'Clave primaria',
    UserName VARCHAR(32) NOT NULL COMMENT 'Username del Usuario',
	FotoPerfil VARCHAR(32) COMMENT 'URL de la imagen de perfil',
    TipoUsuario INT NOT NULL COMMENT 'Indica Persona o Empresa',
    HashPassword VARCHAR(60) NOT NULL COMMENT 'Password', 
	Telefono VARCHAR(12),
  	Email VARCHAR(45) NOT NULL,
    Admin BOOL NOT NULL COMMENT 'Si es o no es admin',
    PRIMARY KEY(IdUsuario)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Usuarios de la aplicacion';

DROP TABLE IF EXISTS Persona;
CREATE TABLE IF NOT EXISTS Persona (
  	IdPersona INT NOT NULL AUTO_INCREMENT COMMENT 'Clave primaria',
  	Nombre VARCHAR(22) NOT NULL,
  	ApellidoPaterno VARCHAR(16) NOT NULL,
  	ApellidoMaterno VARCHAR(16),
	IdUsuario INT NOT NULL COMMENT 'Clave del usuario',
  	Sexo char(1) COMMENT 'HOMBRE(H) O MUJER(M)',
  	FechaNacimiento DATE NOT NULL,
  	PRIMARY KEY (IdPersona),
	FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario)
) 	ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tabla de Personas';

DROP TABLE IF EXISTS Empresa;
CREATE TABLE IF NOT EXISTS Empresa (
  	IdEmpresa INT NOT NULL AUTO_INCREMENT COMMENT 'Clave primaria',
  	Nombre VARCHAR(50) NOT NULL,
  	IdUsuario INT NOT NULL COMMENT 'Clave del usuario',
  	PRIMARY KEY (IdEmpresa),
	FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario)
)	ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='tabla de Empresas';

DROP TABLE IF EXISTS Tag;
CREATE TABLE IF NOT EXISTS Tag (
  	IdTag INT NOT NULL AUTO_INCREMENT COMMENT 'Clave primaria',
  	Tag VARCHAR(45) NOT NULL COMMENT 'Tag para identificar los videos',
  	PRIMARY KEY (IdTag)
) 	ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='tabla de Tags';

DROP TABLE IF EXISTS TipoReaccion;
CREATE TABLE IF NOT EXISTS TipoReaccion (
  	IdTipoReaccion INT NOT NULL AUTO_INCREMENT COMMENT 'Clave primaria',
  	TipoReaccion varchar(20) NOT NULL COMMENT 'Ruta de la imagen para el tipo de reaccion',
  	PRIMARY KEY (IdTipoReaccion)
) 	ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='tabla de los diferentes tipos de reacciones';

DROP TABLE IF EXISTS RalacionFollow;
CREATE TABLE IF NOT EXISTS RelacionFollow(
	IdRelacionFollow INT NOT NULL AUTO_INCREMENT COMMENT 'Clave primaria',
	IdEmisor INT NOT NULL COMMENT 'Id de la persona que sigue al Receptor',
    IdReceptor INT NOT NULL COMMENT 'Id de la persona que es seguida',
    Fecha DATE NOT NULL COMMENT 'Cuando empezo el follow',
	PRIMARY KEY(IdRelacionFollow),
    FOREIGN KEY(IdEmisor) REFERENCES Usuario(IdUsuario) ON DELETE CASCADE,
    FOREIGN KEY(IdReceptor) REFERENCES Usuario(IdUsuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Son relaciones unidireccionales';

DROP TABLE IF EXISTS Publicacion;
CREATE TABLE IF NOT EXISTS Publicacion(
	IdPublicacion INT NOT NULL AUTO_INCREMENT COMMENT 'Clave Primaria',
    IdUsuario INT NOT NULL COMMENT 'El dueño de la publicacion',
    Descripcion VARCHAR(128) COMMENT 'La pequeña descripcion que acompaña al video',
    URLVideo VARCHAR(64) COMMENT 'La direccion del video',
    PRIMARY KEY(IdPublicacion),
    FOREIGN KEY(IdUsuario) REFERENCES Usuario(IdUsuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Publicacion de un video';

DROP TABLE IF EXISTS Comentario;
CREATE TABLE IF NOT EXISTS Comentario(
	IdComentario INT NOT NULL AUTO_INCREMENT COMMENT 'llave primaria',
    IdPublicacion INT NOT NULL COMMENT 'Id de la publicacion donde se comento',
    IdUsuario INT NOT NULL COMMENT 'Id del usuario que comento',
    Comentario VARCHAR(128) NOT NULL COMMENT 'El comentario',
    Fecha DATE NOT NULL COMMENT 'Fecha del comentario',
    PRIMARY KEY(IdComentario),
    FOREIGN KEY(IdPublicacion) REFERENCES Publicacion(IdPublicacion) ON DELETE CASCADE,
    FOREIGN KEY(IdUsuario) REFERENCES Usuario(IdUsuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Camenario que se raliza en una publicacion';

DROP TABLE IF EXISTS Publicacion_Tag;
CREATE TABLE IF NOT EXISTS Publicacion_Tag(
	IdPublicacion INT NOT NULL COMMENT 'Id de la Publicacion',
    IdTag INT NOT NULL COMMENT 'Id del tag',
    FOREIGN KEY(idPublicacion) REFERENCES Publicacion(IdPublicacion),
    FOREIGN KEY(IdTag) REFERENCES Tag(IdTag)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Un tag que se la asigna a una publicacion';

DROP TABLE IF EXISTS Reaccion;
CREATE TABLE IF NOT EXISTS Reaccion(
	IdReaccion INT NOT NULL AUTO_INCREMENT COMMENT 'llave primaria',
    IdPublicacion INT NOT NULL COMMENT 'id de la publicacion donde se reacciono',
    IdUsuario INT NOT NULL COMMENT 'Id del usuario que reacciono',
    IdTipoReaccion INT NOT NULL COMMENT 'El tipo de reaccion que se hizo',
    PRIMARY KEY(IdReaccion),
    FOREIGN KEY(IdPublicacion) REFERENCES Publicacion(IdPublicacion),
    FOREIGN KEY(IdUsuario) REFERENCES Usuario(IdUsuario),
	FOREIGN KEY(IdTipoReaccion) REFERENCES TipoReaccion(IdTipoReaccion)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Reaccion que se hace en una publicacion';

-- CREACION DE TRIGGERS --

-- ELIMINAR LOS TIPOS DE REACCION --
delimiter //
CREATE TRIGGER Eliminar_TipoReaccion
BEFORE DELETE 
ON TipoReaccion FOR EACH ROW
BEGIN
    DELETE FROM Reaccion WHERE IdTipoReaccion = OLD.IdTipoReaccion;
END; //
delimiter ;

-- ELIMINAR LOS TAGS
delimiter //
CREATE TRIGGER Eliminar_Tag
BEFORE DELETE 
ON Tag FOR EACH ROW
BEGIN
    DELETE FROM Publicacion_Tag WHERE IdTag = OLD.IdTag;
END; //
delimiter ;

-- ELIMINAR PUBLICACION --

delimiter //
CREATE TRIGGER Eliminmar_Publicacion
BEFORE DELETE
ON Publicacion FOR EACH ROW
BEGIN
	DELETE FROM Reaccion WHERE IdPublicacion = OLD.IdPublicacion;
    DELETE FROM Publicacion_Tag WHERE IdPublicacion = OLD.IdPublicacion;
    DELETE FROM Comentario WHERE IdPublicacion = OLD.IdPublicacion;
END; //
delimiter ;

-- ELIMINAR USUARIO --

delimiter //
CREATE TRIGGER Eliminar_Usuario
BEFORE DELETE
ON Usuario FOR EACH ROW
BEGIN
	DELETE FROM Publicacion WHERE IdUsuario = OLD.IdUsuario;
    DELETE FROM Comentario WHERE IdUsuario = OLD.IdUsuario;
    DELETE FROM RelacionFollow WHERE (IdEmisor = OLD.IdUsuario OR IdReceptor = OLD.IdUsuario);
	DELETE FROM Reaccion WHERE IdUsuario = OLD.IdUsuario;
END; //
delimiter ;

-- ELIMINAR PERSONA --

delimiter //
CREATE TRIGGER Eliminar_Persona
BEFORE DELETE
ON Persona FOR EACH ROW
BEGIN
	DELETE FROM Usuario WHERE IdUsuario = OLD.IdUsuario;
END; //
delimiter ;

-- ELIMINAR EMPRESA --

delimiter //
CREATE TRIGGER Eliminar_Empresa
BEFORE DELETE
ON Empresa FOR EACH ROW
BEGIN
	DELETE FROM Usuario WHERE IdUsuario = OLD.IdUsuario;
END; //
delimiter ;

-- INSERTS DE PRUEBA --

INSERT INTO Usuario(UserName, TipoUsuario, HashPassword, Email, Admin ) VALUES
('RubenRETM',1,'1234','ruben_3o@hotmail.com',TRUE),
('Diegoias',1,'1234','diego_algo@gmail.com',TRUE);

INSERT INTO Persona(Nombre,ApellidoPaterno, ApellidoMaterno, IdUsuario,Sexo,FechaNacimiento) VALUES
('Ruben Elihu','Trujano','Miranda', 1, 'H','1998-10-03'),
('Diego Israel', 'Alcnatara','Salvitano',2,'H','1998-05-15');

-- ELIMINAR TODO --

#DROP TABLE IF EXISTS Comentario;
#DROP TABLE IF EXISTS Publicacion_Tag;
#DROP TABLE IF EXISTS Tag;
#DROP TABLE IF EXISTS Reaccion;
#DROP TABLE IF EXISTS TipoReaccion;
#DROP TABLE IF EXISTS Publicacion;
#DROP TABLE IF EXISTS RelacionFollow;
#DROP TABLE IF EXISTS Usuario;
#DROP TABLE IF EXISTS Persona;
#DROP TABLE IF EXISTS Empresa;
#DROP TABLE IF EXISTS TipoUsuario;
