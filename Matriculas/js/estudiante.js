class Estudiante{
    constructor(){
        this._nombre = "";
        this._apellido = "";
        this._edad = 0;
        this._grado = 0;
        this._jornada = "";
    }

    get Nombre(){
        return this._nombre;
    }

    get Apellido(){
        return this._apellido;
    }

    get Edad(){
        return this._edad;
    }

    get Grado(){
        return this._grado;
    }

    get Jornada(){
        return this._jornada;
    }

    set Nombre(nombre){
        this._nombre =  nombre;
    }

    set Apellido(apellido){
        this._apellido = apellido;
    }

    set Edad(edad){
        this._edad = edad;
    }

    set Grado(grado){
        this._grado = grado;
    }

    set Jornada(jornada){
        this._jornada =  jornada;
    }
}