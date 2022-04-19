const primero = [];
const segundo = [];
const tercero = [];
const cuarto = [];


const formulario =  document.forms['form'];
let nombre = formulario['nombre'];
let apellido = formulario['apellido'];
let edad = formulario['edad'];

const limpiar = () => {
    nombre.value = "";
    apellido.value = "";
    edad.value = "";
}

const matricularEstudiante = () => {
    let estudiante =  new Estudiante();
    if(nombre.value != "" && apellido.value != "" && (edad.value > 4 && edad.value < 18)){
        estudiante.Nombre = nombre.value;
        estudiante.Apellido = apellido.value;
        estudiante.Edad = edad.value;
        if(estudiante.Edad >=5 && estudiante.Edad <= 7){
            if(primero.length == 5){
                alert("El grado primero ya está lleno.");
            } else {
                estudiante.Grado = 1;
                estudiante.Jornada = "Mañana";
                primero.push(Object(estudiante));
            }
        } else if(estudiante.Edad >= 8 && estudiante.Edad < 12){
            if(segundo.length == 5){
                alert("El grado segundo ya está lleno.");
            } else {
                estudiante.Grado = 2;
                estudiante.Jornada = "Tarde";
                segundo.push(estudiante);
            }
        } else if (estudiante.Edad >= 12 && estudiante.Edad <= 15){
            if(tercero.length == 5){
                alert("El grado tercero ya está lleno.");
            } else {
                estudiante.Grado = 3;
                estudiante.Jornada = "Mañana";
                tercero.push(estudiante);
            }
        } else if (estudiante.Edad >= 16 && estudiante.Edad <= 17){
            if(cuarto.length == 5){
                alert("El grado cuarto ya está lleno.");
            } else {
                estudiante.Grado = 4;
                estudiante.Jornada = "tarde";
                cuarto.push(estudiante);
            }
        }
        limpiar();
    } else {
        alert("Verifique que estén llenos todos los campos o que la edad sea mayor a 4 y menor que 18.");
    }
}

const boton = document.getElementById("matricular");
boton.addEventListener("click", (e) => {
    e.preventDefault();
    matricularEstudiante();
    let html = ""
    primero.forEach(est =>{
         html += `
         <tr>
            <td>${est.Nombre}</td>
            <td>${est.Apellido}</td>
            <td>${est.Edad}</td>
            <td>${est.Grado}</td>
            <td>${est.Jornada}</td>
        </tr>
            `;
    });
    segundo.forEach(est =>{
         html += `
         <tr>
            <td>${est.Nombre}</td>
            <td>${est.Apellido}</td>
            <td>${est.Edad}</td>
            <td>${est.Grado}</td>
            <td>${est.Jornada}</td>
        </tr>
            `;
    });
    tercero.forEach(est =>{
         html += `
         <tr>
            <td>${est.Nombre}</td>
            <td>${est.Apellido}</td>
            <td>${est.Edad}</td>
            <td>${est.Grado}</td>
            <td>${est.Jornada}</td>
        </tr>
            `;
    });
    cuarto.forEach(est =>{
         html += `
         <tr>
            <td>${est.Nombre}</td>
            <td>${est.Apellido}</td>
            <td>${est.Edad}</td>
            <td>${est.Grado}</td>
            <td>${est.Jornada}</td>
        </tr>
            `;
    });
    document.getElementById("primero").innerHTML = html;
});