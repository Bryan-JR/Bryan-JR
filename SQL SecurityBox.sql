create database if not exists SecurityBox;
USE SecurityBox;

CREATE TABLE imagenPerfil (
  idImg INTEGER UNSIGNED  NOT NULL   AUTO_INCREMENT,
  nombre VARCHAR(100)  NULL  ,
  img MEDIUMBLOB  NULL  ,
  extension VARCHAR(5)  NULL    ,
PRIMARY KEY(idImg));

CREATE TABLE sitio (
  idsitio INTEGER UNSIGNED  NOT NULL   AUTO_INCREMENT,
  nombre VARCHAR(100)  NULL  ,
  url VARCHAR(400)  NULL    ,
PRIMARY KEY(idsitio));

CREATE TABLE cliente (
  nDocumento INTEGER UNSIGNED  NOT NULL  ,
  nombre VARCHAR(100)  NOT NULL  ,
  apellido VARCHAR(100)  NOT NULL  ,
  tipoDocumento VARCHAR(10)  NOT NULL  ,
  fechaNa DATE  NOT NULL  ,
  genero VARCHAR(10)  NOT NULL    ,
PRIMARY KEY(nDocumento));

CREATE TABLE CuentaSB (
  idSB INTEGER UNSIGNED  NOT NULL   AUTO_INCREMENT,
  idImg INTEGER UNSIGNED  NULL  ,
  nDocumento INTEGER UNSIGNED  NOT NULL  ,
  usuario VARCHAR(100)  NOT NULL  ,
  correo VARCHAR(120)  NOT NULL  ,
  contraseña VARCHAR(100)  NOT NULL    ,
PRIMARY KEY(idSB)  ,
INDEX CuentaSB_FKIndex1(nDocumento)  ,
INDEX CuentaSB_FKIndex2(idImg),
  FOREIGN KEY(nDocumento)
    REFERENCES cliente(nDocumento)
      ON DELETE RESTRICT
      ON UPDATE CASCADE,
  FOREIGN KEY(idImg)
    REFERENCES imagenPerfil(idImg)
      ON DELETE RESTRICT
      ON UPDATE CASCADE);

CREATE TABLE cuentas (
  idcuenta INTEGER UNSIGNED  NOT NULL   AUTO_INCREMENT,
  idsitio INTEGER UNSIGNED  NOT NULL  ,
  idSB INTEGER UNSIGNED  NOT NULL  ,
  correoUsuario VARCHAR(150)  NULL  ,
  contraseña VARCHAR(100)  NULL    ,
PRIMARY KEY(idcuenta)  ,
INDEX cuentas_FKIndex1(idSB)  ,
INDEX cuentas_FKIndex2(idsitio),
  FOREIGN KEY(idSB)
    REFERENCES CuentaSB(idSB)
      ON DELETE RESTRICT
      ON UPDATE CASCADE,
  FOREIGN KEY(idsitio)
    REFERENCES sitio(idsitio)
      ON DELETE RESTRICT
      ON UPDATE CASCADE);

-- Importante
-- SET GLOBAL log_bin_trust_function_creators = 1;
DELIMITER $$
DROP FUNCTION IF EXISTS verificarCorreo$$
CREATE FUNCTION verificarCorreo(entrada VARCHAR(150))
RETURNS INT
BEGIN
DECLARE contador INT DEFAULT 0;
SELECT COUNT(idSB) INTO contador FROM cuentaSB WHERE correo=entrada;
IF contador=0 THEN
	RETURN 1; -- No esta registra, por lo que se puede registrar
END IF;
END$$
DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS verificarUsuario$$
CREATE FUNCTION verificarUsuario(entrada VARCHAR(150))
RETURNS BOOLEAN
BEGIN
DECLARE contador INT DEFAULT 0;
SELECT COUNT(idSB) INTO contador FROM cuentaSB WHERE usuario=entrada;
IF contador=0 THEN
	RETURN 1; -- No esta registra, por lo que se puede registrar
END IF;
END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS nuevoRegistro$$
CREATE PROCEDURE nuevoRegistro(nDocumentoEntrada INTEGER,
  nombreEntrada VARCHAR(100),
  apellidoEntrada VARCHAR(100),
  tipoDocumentoEntrada VARCHAR(10),
  fechaNaEntrada DATE,
  generoEntrada VARCHAR(10),
  usuarioEntrada VARCHAR(100),
  correoEntrada VARCHAR(120),
  contraseñaEntrada VARCHAR(100)
  )
  BEGIN
  IF verificarCorreo(correoEntrada) THEN
	IF verificarUsuario(contraseñaEntrada) THEN
		INSERT INTO cliente(nDocumento, nombre, apellido, tipoDocumento, fechaNa, genero)
			VALUES
			(nDocumentoEntrada, nombreEntrada, apellidoEntrada, tipoDocumentoEntrada, fechaNaEntrada, generoEntrada);
		INSERT INTO CuentaSB(idImg, nDocumento, usuario, correo, contraseña)
			values
			(null, nDocumentoEntrada, usuarioEntrada, correoEntrada, contraseñaEntrada);
	ELSE 
		SELECT "Usuario existe";
    END IF;
ELSE
	SELECT "Correo Existe";
END IF;
END$$
DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS comprobarCuenta $$
CREATE FUNCTION comprobarCuenta(usuario VARCHAR(100), correo VARCHAR(120))
RETURNS INT
BEGIN
END$$
DELIMITER ;SET GLOBAL log_bin_trust_function_creators = 1
