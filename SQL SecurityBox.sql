-- Creación de la base de datos
CREATE DATABASE SecurityBox;
USE SecurityBox;

-- Creación de las tablas
CREATE TABLE ImagenPerfil (
  idImg INTEGER UNSIGNED  NOT NULL   AUTO_INCREMENT,
  nombre VARCHAR(100)  NULL  ,
  img MEDIUMBLOB  NULL  ,
  extension VARCHAR(5)  NULL    ,
PRIMARY KEY(idImg));



CREATE TABLE Usuario (
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
  nomUsuario VARCHAR(100)  NOT NULL  ,
  correo VARCHAR(120)  NOT NULL  ,
  contraseña VARCHAR(100)  NOT NULL    ,
PRIMARY KEY(idSB)  ,
INDEX CuentaSB_FKIndex1(nDocumento)  ,
INDEX CuentaSB_FKIndex2(idImg),
  FOREIGN KEY(nDocumento)
    REFERENCES Usuario(nDocumento)
      ON DELETE RESTRICT
      ON UPDATE CASCADE,
  FOREIGN KEY(idImg)
    REFERENCES ImagenPerfil(idImg)
      ON DELETE RESTRICT
      ON UPDATE CASCADE);

CREATE TABLE Actualizacion_CuentaSB (
  id INTEGER UNSIGNED  NOT NULL   AUTO_INCREMENT,
  idSB INTEGER UNSIGNED  NOT NULL  ,
  contraseñaVieja VARCHAR(100)  NOT NULL  ,
  contraseñaNueva VARCHAR(100)  NOT NULL  ,
  fecha DATETIME  NOT NULL    ,
PRIMARY KEY(id));

CREATE TABLE Sitio (
  idsitio INTEGER UNSIGNED  NOT NULL   AUTO_INCREMENT,
  idSB INTEGER UNSIGNED  NOT NULL  ,
  nombre VARCHAR(100)  NULL  ,
  url VARCHAR(400)  NULL    ,
PRIMARY KEY(idsitio)  ,
INDEX Sitio_FKIndex1(idSB),
  FOREIGN KEY(idSB)
    REFERENCES CuentaSB(idSB)
      ON DELETE RESTRICT
      ON UPDATE CASCADE);



CREATE TABLE Cuentas (
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
    REFERENCES Sitio(idsitio)
      ON DELETE RESTRICT
      ON UPDATE CASCADE);
      
CREATE TABLE CuentasEliminadas (
  id INTEGER UNSIGNED  NOT NULL   AUTO_INCREMENT,
  idcuenta INTEGER UNSIGNED  NOT NULL  ,
  correo VARCHAR(120)  NOT NULL  ,
  contraseña VARCHAR(100)  NOT NULL  ,
  fecha DATETIME  NOT NULL    ,
PRIMARY KEY(id));

CREATE TABLE ActualizarCuenta (
  id INTEGER UNSIGNED  NOT NULL   AUTO_INCREMENT,
  idcuenta INTEGER UNSIGNED  NOT NULL  ,
  sitioViejo INTEGER UNSIGNED  NOT NULL  ,
  sitioNuevo INTEGER UNSIGNED  NOT NULL  ,
  correoViejo VARCHAR(120)  NOT NULL  ,
  correoNuevo VARCHAR(120)  NOT NULL  ,
  contraseñaVieja VARCHAR(100)  NOT NULL  ,
  contraseñaNueva VARCHAR(100)  NOT NULL  ,
  fecha DATETIME  NOT NULL    ,
PRIMARY KEY(id));

/*SUBCONSULTAS*/
SELECT nomUsuario FROM CuentaSB WHERE idSB=1; -- Muestra el usuario de la cuenta;
SELECT * FROM Sitio WHERE idSB=1;
SELECT * FROM Cuentas NATURAL JOIN Sitio WHERE idSB=1; -- Mostrara todas las cuentas de la cuenta iniciada.
SELECT * FROM Cuentas NATURAL JOIN Sitio WHERE idSB=1 AND idcuenta=1; -- Mostrara info de una sola cuenta.
SELECT * FROM Cuentas NATURAL JOIN Sitio WHERE idSB=1 AND nombre LIKE "%Face%"; -- filtrar las cuentas por sitio.


/*PROCEDIMIENTOS*/
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
  IF verificarCorreo(correoEntrada)=0 THEN
	IF verificarUsuario(usuarioEntrada)=0 THEN
		INSERT INTO Usuario(nDocumento, nombre, apellido, tipoDocumento, fechaNa, genero)
			VALUES
			(nDocumentoEntrada, nombreEntrada, apellidoEntrada, tipoDocumentoEntrada, fechaNaEntrada, generoEntrada);
		INSERT INTO CuentaSB(idImg, nDocumento, nomUsuario, correo, contraseña)
			values
			(null, nDocumentoEntrada, usuarioEntrada, correoEntrada, contraseñaEntrada);
		SELECT "Datos guardados";
	ELSE 
		SELECT "Usuario existe";
    END IF;
ELSE
	SELECT "Correo Existe";
END IF;
END$$
DELIMITER ;
CALL nuevoRegistro(1001032253, "brayan", "jimenez", "CC", "2000-12-14", "M", "Bryan14", "brayanjiru14@gmail.com", "qwe..123");
SELECT * FROM CuentaSB NATURAL JOIN Usuario;

DELIMITER $$
DROP PROCEDURE IF EXISTS comprobarCuenta $$
CREATE PROCEDURE comprobarCuenta(entrada VARCHAR(120), entradaContraseña VARCHAR(100))
BEGIN
DECLARE cont INT DEFAULT 0;
DECLARE pass VARCHAR(100);
SELECT COUNT(*) INTO cont FROM CuentaSB WHERE correo=entrada OR nomUsuario=entrada;
SELECT contraseña INTO pass FROM CuentaSB WHERE correo=entrada OR nomUsuario=entrada;
IF cont>0 THEN
	IF STRCMP(pass,BINARY entradaContraseña)=0 THEN
		SELECT "iniciado"; -- Si la contraseña es correcta se inicia sesión
	ELSE
		SELECT "incorrecta"; -- Si es incorrecta no se inicia
    END IF;
ELSE
	SELECT "no existe"; -- Si el contador es 0, quiere decir que la cuenta no existe 
END IF;
END$$
DELIMITER ;
CALL comprobarCuenta("brayanjiru14@gmail.com", "qwe..123");

DELIMITER $$
DROP PROCEDURE IF EXISTS guardarSitio $$
CREATE PROCEDURE guardarSitio(IN idEntrada INT,IN nombreSitio VARCHAR(100), IN urlSitio VARCHAR(400))
BEGIN
	INSERT INTO Sitio(idSB, nombre, url) VALUES (idEntrada, nombreSitio, urlSitio);
END $$
DELIMITER ;
CALL guardarSitio(1, "Facebook", "www.facebook.com");

DELIMITER $$
DROP PROCEDURE IF EXISTS guardarCuentas $$
CREATE PROCEDURE guardarCuentas(
	IN entradaId INT, 
	IN correoEntrada VARCHAR(150), 
	IN contraseñaEntrada VARCHAR(100),
    IN idSitio INT
    )
BEGIN
    INSERT INTO Cuentas(idsitio, idSB, correoUsuario, contraseña) VALUES (idSitio, entradaId, correoEntrada, contraseñaEntrada);
END $$
DELIMITER ;
CALL guardarCuentas(1, "juan123", "qwe123", 1);
SELECT * FROM Cuentas NATURAL JOIN Sitio;

/*FUNCIONES*/
DELIMITER $$
DROP FUNCTION IF EXISTS verificarCorreo$$
CREATE FUNCTION verificarCorreo(entrada VARCHAR(150))
RETURNS INT
BEGIN
DECLARE contador INT DEFAULT 1;
SELECT COUNT(idSB) INTO contador FROM CuentaSB WHERE correo=entrada;
RETURN contador; -- Si es 0 no esta registra, por lo que se puede registrar
END$$
DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS verificarUsuario$$
CREATE FUNCTION verificarUsuario(entrada VARCHAR(150))
RETURNS BOOLEAN
BEGIN
DECLARE contador INT DEFAULT 1;
SELECT COUNT(idSB) INTO contador FROM CuentaSB WHERE nomUsuario=entrada;
RETURN contador; -- Si es 0 no esta registra, por lo que se puede registrar
END$$
DELIMITER ;

/*TRIGGERS-DISPARADORES*/
DELIMITER $$
DROP TRIGGER IF EXISTS actualizacionContraseña$$
CREATE TRIGGER actualizacionContraseña
AFTER UPDATE ON CuentaSB
FOR EACH ROW
BEGIN
	INSERT INTO Actualizacion_CuentaSB(idSB, contraseñaVieja, contraseñaNueva, fecha) 
		VALUES
        (OLD.idSB, OLD.contraseña, NEW.contraseña, NOW());
END $$
DELIMITER ;
UPDATE CuentaSB SET contraseña="QWE_123" WHERE idSB=1;
SELECT * FROM CuentaSB;
SELECT * FROM Actualizacion_CuentaSB;

DELIMITER $$
DROP TRIGGER IF EXISTS actualizacionCuenta$$
CREATE TRIGGER actualizacionCuenta
AFTER UPDATE ON Cuentas
FOR EACH ROW
BEGIN
	INSERT INTO ActualizarCuenta(idcuenta, sitioViejo, sitioNuevo, correoViejo, correoNuevo, contraseñaVieja, contraseñaNueva, fecha) 
		VALUES
        (OLD.idcuenta, OLD.idsitio, NEW.idsitio, OLD.correoUsuario, NEW.correoUsuario, OLD.contraseña, NEW.contraseña, NOW());
END $$
DELIMITER ;
UPDATE Cuentas SET idsitio=1, correoUsuario="brayan14@gmail.com", contraseña="123450" WHERE idcuenta=2;
SELECT * FROM Cuentas;
SELECT * FROM ActualizarCuenta;

DELIMITER $$
DROP TRIGGER IF EXISTS EliminaCuenta$$
CREATE TRIGGER EliminaCuenta
BEFORE DELETE ON Cuentas
FOR EACH ROW
BEGIN
	INSERT INTO CuentasEliminadas(idcuenta, correo, contraseña, fecha) 
		VALUES
        (OLD.idcuenta, OLD.correoUsuario, OLD.contraseña, NOW());
END $$
DELIMITER ;

DELETE FROM Cuentas WHERE idcuenta=2;
SELECT * FROM Cuentas;
SELECT * FROM CuentasEliminadas;