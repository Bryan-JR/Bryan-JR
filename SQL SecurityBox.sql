-- Creación de la base de datos
-- DROP DATABASE SecurityBox;
CREATE DATABASE SecurityBox;
USE SecurityBox;

-- Creación de las tablas
CREATE TABLE ImagenPerfil (
  idImg INTEGER UNSIGNED  NOT NULL   AUTO_INCREMENT,
  nombre VARCHAR(500)  NULL ,
PRIMARY KEY(idImg));

CREATE TABLE Usuario (
  nDocumento INTEGER UNSIGNED  NOT NULL  ,
  nombre1 VARCHAR(40)  NOT NULL  ,
  nombre2 VARCHAR(40)  NULL  ,
  apellido1 VARCHAR(40)  NOT NULL  ,
  apellido2 VARCHAR(40)  NOT NULL  ,
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
  contraseña VARBINARY(400)  NOT NULL    ,
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
      
      INSERT INTO ImagenPerfil (idImg, nombre) Values (1, '/fotosPerfil/defecto.jpg');
      

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
  contraseña VARBINARY(500)  NULL    ,
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


/*Tablas para triggers*/
CREATE TABLE Actualizacion_CuentaSB (
  id INTEGER UNSIGNED  NOT NULL   AUTO_INCREMENT,
  idSB INTEGER UNSIGNED  NOT NULL  ,
  contraseñaVieja VARBINARY(500)  NOT NULL  ,
  contraseñaNueva VARBINARY(500)  NOT NULL  ,
  fecha DATETIME  NOT NULL    ,
PRIMARY KEY(id));
      
CREATE TABLE CuentasEliminadas (
  id INTEGER UNSIGNED  NOT NULL   AUTO_INCREMENT,
  idcuenta INTEGER UNSIGNED  NOT NULL  ,
  correo VARCHAR(120)  NOT NULL  ,
  contraseña VARBINARY(500)  NOT NULL  ,
  fecha DATETIME  NOT NULL    ,
PRIMARY KEY(id));

CREATE TABLE ActualizarCuenta (
  id INTEGER UNSIGNED  NOT NULL   AUTO_INCREMENT,
  idcuenta INTEGER UNSIGNED  NOT NULL,
  sitioViejo INTEGER UNSIGNED  NOT NULL,
  sitioNuevo INTEGER UNSIGNED  NOT NULL,
  correoViejo VARCHAR(120)  NOT NULL,
  correoNuevo VARCHAR(120)  NOT NULL,
  contraseñaVieja VARBINARY(500)  NOT NULL,
  contraseñaNueva VARBINARY(500)  NOT NULL,
  fecha DATETIME  NOT NULL,
PRIMARY KEY(id));

/*CONSULTAS*/
SELECT nomUsuario FROM CuentaSB WHERE idSB=2; -- Muestra el usuario de la cuenta;
SELECT * FROM Sitio WHERE idSB=1;

/*SUBCONSULTAS*/
-- 1
SELECT *, (SELECT nombre FROM Sitio 
				WHERE idsitio=c.idsitio) Sitio, 
            (SELECT url FROM Sitio 
				WHERE idsitio=c.idsitio) url FROM Cuentas c 
WHERE idSB=1; -- Mostrara todas las cuentas de la cuenta iniciada.

-- 2
SELECT *, (SELECT nombre FROM Sitio 
				WHERE idsitio=c.idsitio) Sitio, 
            (SELECT url FROM Sitio 
				WHERE idsitio=c.idsitio) url FROM Cuentas c
WHERE idSB=2 AND idcuenta=1; -- Mostrara info de una sola cuenta.

-- 3
SELECT *, (SELECT nombre FROM Sitio 
				WHERE idsitio=c.idsitio) as Sitio, 
            (SELECT url FROM Sitio 
				WHERE idsitio=c.idsitio) as url FROM Cuentas c
WHERE idSB=2 AND c.idsitio IN (SELECT idsitio FROM Sitio WHERE nombre LIKE "%Ins%"); -- filtrar las cuentas por sitio.


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

/*PROCEDIMIENTOS*/
DELIMITER $$
DROP PROCEDURE IF EXISTS nuevoRegistro$$
CREATE PROCEDURE nuevoRegistro(nDocumentoEntrada INTEGER,
  nombre1Entrada VARCHAR(40),
  nombre2Entrada VARCHAR(40),
  apellido1Entrada VARCHAR(40),
  apellido2Entrada VARCHAR(40),
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
		INSERT INTO Usuario(nDocumento, nombre1, nombre2, apellido1, apellido2, tipoDocumento, fechaNa, genero)
			VALUES
			(nDocumentoEntrada, nombre1Entrada, nombre2Entrada, apellido1Entrada, apellido2Entrada, tipoDocumentoEntrada, fechaNaEntrada, generoEntrada);
		INSERT INTO CuentaSB(idImg, nDocumento, nomUsuario, correo, contraseña)
			values
			(null, nDocumentoEntrada, usuarioEntrada, correoEntrada, AES_ENCRYPT(contraseñaEntrada, "superSB"));
		SELECT "guardado" valor;
	ELSE 
		SELECT "usuario existe" valor;
    END IF;
ELSE
	SELECT "correo existe" valor;
END IF;
END$$
DELIMITER ;
CALL nuevoRegistro(34234,"Brayan","Steven","Jimenez","Ruiz","CC","2000-12-12","M","A1", "DFFGF@gmail.com", "QWE.123");
SELECT * FROM CuentaSB where contraseña = aes_encrypt("qwe.123", "superSB");

DELIMITER $$
DROP PROCEDURE IF EXISTS comprobarInicio $$
CREATE PROCEDURE comprobarInicio(entrada VARCHAR(120), entradaContraseña VARCHAR(100))
BEGIN
DECLARE cont INT DEFAULT 0;
DECLARE pass VARBINARY(400); 
SELECT COUNT(*) INTO cont FROM CuentaSB WHERE correo=entrada OR nomUsuario=entrada;
SELECT contraseña INTO pass FROM CuentaSB WHERE correo=entrada OR nomUsuario=entrada;
IF cont>0 THEN
	IF pass=AES_ENCRYPT(entradaContraseña, "superSB") THEN 
		SELECT SHA2(idSB, 224) as idSB, nomUsuario, "iniciado" valor FROM CuentaSB WHERE correo=entrada OR nomUsuario=entrada;
		-- Si la contraseña es correcta se inicia sesión
	ELSE
		SELECT "incorrecta" valor, pass, AES_ENCRYPT(entradaContraseña, "superSB"); -- Si es incorrecta no se inicia
    END IF;
ELSE
	SELECT "no existe" valor; -- Si el contador es 0, quiere decir que la cuenta no existe 
END IF;
END$$
DELIMITER ;
CALL comprobarInicio("A1", "QWE.123");
select SHA2(idSB, 224) from CuentaSB;

DELIMITER $$
DROP PROCEDURE IF EXISTS buscarImg $$
CREATE PROCEDURE buscarImg(id VARCHAR(500))
BEGIN
	DECLARE idImagen INTEGER DEFAULT 1;
    SELECT idImg into idImagen FROM CuentaSB WHERE SHA2(idSB, 224) = id;
	SELECT nombre FROM ImagenPerfil WHERE idImg = idImagen;
END$$
DELIMITER ;
CALL buscarImg(3);

DELIMITER $$
DROP PROCEDURE IF EXISTS guardarSitio $$
CREATE PROCEDURE guardarSitio(IN idEntrada VARCHAR(400),IN nombreSitio VARCHAR(100), IN urlSitio VARCHAR(400))
BEGIN
	DECLARE id INTEGER;
    SELECT idSB INTO id FROM CuentaSB WHERE SHA2(idSB, 224) = idEntrada;
	INSERT INTO Sitio(idSB, nombre, url) VALUES (id, nombreSitio, urlSitio);
END $$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS guardarCuentas $$
CREATE PROCEDURE guardarCuentas(
	IN entradaId VARCHAR(400), 
	IN correoEntrada VARCHAR(150), 
	IN contraseñaEntrada VARCHAR(100),
    IN idSitio INT
    )
BEGIN
	DECLARE id INTEGER;
    SELECT idSB INTO id FROM CuentaSB WHERE SHA2(idSB, 224) = entradaId;
    INSERT INTO Cuentas(idsitio, idSB, correoUsuario, contraseña) 
    VALUES 
    (idSitio, id, correoEntrada, AES_ENCRYPT(contraseñaEntrada, "superSB"));
END $$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS eliminarCuentaSB$$
CREATE PROCEDURE eliminarCuentaSB(id VARCHAR(400))
BEGIN
	DECLARE nid INTEGER;
    DECLARE img INTEGER;
	DELETE FROM Cuentas WHERE SHA2(idSB, 224)=id;
    DELETE FROM Sitio WHERE SHA2(idSB, 224)=id;
    SELECT nDocumento INTO nid FROM CuentaSB WHERE SHA2(idSB, 224)=id;
    SELECT idImg INTO img FROM CuentaSB WHERE SHA2(idSB, 224)=id;
    DELETE FROM CuentaSB WHERE SHA2(idSB, 224) = id;
    DELETE FROM ImagenPerfil WHERE idImg = img;
    DELETE FROM Usuario WHERE nDocumento = nid;
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
