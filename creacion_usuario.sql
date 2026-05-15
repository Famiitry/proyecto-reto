-- Conectarse como SYS o SYSTEM
sqlplus sys as sysdba

-- Crear usuario
CREATE USER SistemaMedico IDENTIFIED BY 123456789;

-- Dar permisos básicos
GRANT CONNECT, RESOURCE TO SistemaMedico;

-- Permitir crear tablas, vistas, secuencias, procedimientos, etc.
GRANT CREATE SESSION TO SistemaMedico;
GRANT CREATE TABLE TO SistemaMedico;
GRANT CREATE VIEW TO SistemaMedico;
GRANT CREATE SEQUENCE TO SistemaMedico;
GRANT CREATE PROCEDURE TO SistemaMedico;
GRANT CREATE TRIGGER TO SistemaMedico;

-- Asignar espacio ilimitado en USERS
ALTER USER SistemaMedico QUOTA UNLIMITED ON USERS;