const POOL_PREGUNTAS = [
  {
    pregunta: "¿Cómo se llama la aplicación de este proyecto?",
    opciones: ["Mi Barrio Seguro", "Vecino Alerta", "Sucre Protegida", "Barrio Conectado"],
    correcta: 0,
    dato: "MI BARRIO SEGURO nació para que los vecinos se protejan entre sí."
  },
  {
    pregunta: "¿En qué ciudad de Bolivia se implementó primero la aplicación?",
    opciones: ["La Paz", "Cochabamba", "Sucre", "Santa Cruz"],
    correcta: 2,
    dato: "El proyecto piloto arrancó en barrios de Sucre, con miras a escalar a todo el municipio."
  },
  {
    pregunta: "¿Cuántos botones de emergencia tiene la pantalla principal de la app?",
    opciones: ["2", "3", "4", "6"],
    correcta: 2,
    dato: "Policía, Bomberos, Ambulancia y Servicios Básicos: cuatro caminos directos a la ayuda."
  },
  {
    pregunta: "¿Qué envía la app automáticamente cuando un vecino emite una alerta?",
    opciones: ["Una factura", "Su ubicación GPS exacta", "Un saludo al grupo", "Una encuesta"],
    correcta: 1,
    dato: "La coordenada GPS viaja con la alerta para que nadie tenga que explicar dónde está en plena emergencia."
  },
  {
    pregunta: "¿En qué instituto se desarrolló este proyecto de grado?",
    opciones: ["ITSEC Sucre", "Univ. Mayor de San Andrés", "Colegio Auroro", "ITS Monteagudo"],
    correcta: 0,
    dato: "Fue creado en la Carrera de Sistemas Informáticos del ITSEC SUCRE."
  },
  {
    pregunta: "¿Cuál es el propósito principal de MI BARRIO SEGURO?",
    opciones: ["Vender productos del barrio", "Entretener con juegos", "Proteger al barrio en emergencias", "Enseñar a cocinar"],
    correcta: 2,
    dato: "Es una herramienta social: su única misión es que la ayuda llegue a tiempo y salvar vidas."
  },
  {
    pregunta: "¿Qué problema tenían los grupos de WhatsApp en una emergencia real?",
    opciones: ["Eran muy rápidos", "Los pedidos de auxilio se perdían entre tantos mensajes", "No tenían internet", "Cobraban por mensaje"],
    correcta: 1,
    dato: "Un pedido de ayuda se hundía entre cadenas, memes y saludos; la app lo pone en primer plano."
  },
  {
    pregunta: "¿Qué dos tipos de usuarios puede registrar la aplicación?",
    opciones: ["Vecino y Agente", "Comprador y Vendedor", "Profesor y Alumno", "Conductor y Pasajero"],
    correcta: 0,
    dato: "El vecino alerta y el agente institucional (Policía, Bomberos, etc.) atiende desde su panel."
  },
  {
    pregunta: "¿Cómo se llama el espacio donde los vecinos proponen mejoras para la app?",
    opciones: ["El buzón de quejas", "El buzón de sugerencias", "La caja de ideas", "El foro vecinal"],
    correcta: 1,
    dato: "El buzón de sugerencias alimenta el mejoramiento continuo del sistema."
  },
  {
    pregunta: "¿Qué botón pulsa el agente en su panel cuando ya resolvió un incidente?",
    opciones: ["Listo", "Cerrar turno", "Atendido", "Finalizar"],
    correcta: 2,
    dato: "Con 'Atendido', la alerta deja de estar activa y el mapa del barrio se actualiza."
  },
  {
    pregunta: "¿Cuál de estos NO es un tipo de reporte vecinal en la app?",
    opciones: ["Cable caído", "Fuga de agua", "Alumbrado dañado", "Venta de comida"],
    correcta: 3,
    dato: "Los reportes son de riesgos urbanos: cable caído, fuga de agua, alumbrado y sospechosos."
  },
  {
    pregunta: "¿Dónde ve el agente institucional los incidentes activos del barrio?",
    opciones: ["En un mapa en tiempo real", "En un periódico", "En una pizarra", "Por carta"],
    correcta: 0,
    dato: "El panel del agente muestra cada incidente como un marcador sobre el mapa de la ciudad."
  },
  {
    pregunta: "¿Qué pueden hacer los vecinos en el chat de la aplicación?",
    opciones: ["Vender ropa", "Dar avisos importantes a la comunidad", "Jugar en línea", "Ver películas"],
    correcta: 1,
    dato: "El chat vecinal es el canal de la comunidad, con mensajes oficiales destacados en rojo."
  },
  {
    pregunta: "¿La aplicación permite comprar o vender cosas?",
    opciones: ["Sí, tiene tienda", "Solo los fines de semana", "No, es solo para la seguridad", "Solo con tarjetas"],
    correcta: 2,
    dato: "Cero funciones comerciales: el propósito es estrictamente social y salvar vidas."
  },
  {
    pregunta: "¿Qué institución acude si pulsas el botón de emergencia de los bomberos?",
    opciones: ["La Alcaldía", "El Cuerpo de Bomberos", "El registro civil", "La escuela"],
    correcta: 1,
    dato: "Cada botón está conectado al área de auxilio correcta: Policía, Bomberos, Ambulancia o Servicios Básicos."
  }
];

const TOTAL_CARTAS = 9;
const MAX_CARTAS = 5;
const ACIERTOS_PARA_GANAR = 3;

let cartas = [];
let aciertos = 0;
let cartasUsadas = 0;
let indiceCartaActual = -1;
let bloqueado = false;

const $ = (id) => document.getElementById(id);

function mostrarPantalla(id) {
  document.querySelectorAll(".pantalla").forEach((p) => p.classList.remove("activa"));
  $(id).classList.add("activa");
}

function mezclarArray(arr) {
  const copia = [...arr];
  for (let i = copia.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copia[i], copia[j]] = [copia[j], copia[i]];
  }
  return copia;
}

function iniciarJuego() {
  cartas = mezclarArray(POOL_PREGUNTAS).slice(0, TOTAL_CARTAS);
  aciertos = 0;
  cartasUsadas = 0;
  bloqueado = false;
  $("contador-aciertos").textContent = "0";
  $("contador-cartas").textContent = "0";
  $("texto-ayuda").textContent = "Elige una carta para revelar su pregunta";
  pintarTablero();
  mostrarPantalla("pantalla-juego");
  animarMezcla();
}

function pintarTablero() {
  const tablero = $("tablero");
  tablero.innerHTML = "";
  cartas.forEach((carta, i) => {
    const btn = document.createElement("button");
    btn.className = "carta";
    btn.dataset.indice = i;
    btn.setAttribute("aria-label", "Carta " + (i + 1));
    btn.innerHTML = `
      <div class="cara cara-verso">
        <div class="escudo">MBS</div>
        <span class="texto-verso">Mi Barrio Seguro</span>
      </div>
      <div class="cara cara-frente">
        <div class="resultado-carta"></div>
        <span class="pregunta-corta">${carta.pregunta}</span>
      </div>
    `;
    btn.addEventListener("click", () => elegirCarta(i));
    tablero.appendChild(btn);
  });
}

function animarMezcla() {
  const tablero = $("tablero");
  const cartasDOM = [...tablero.children];
  cartasDOM.forEach((c) => {
    c.style.setProperty("--mx", (Math.random() * 260 - 130).toFixed(0) + "px");
    c.style.setProperty("--my", (Math.random() * 160 - 80).toFixed(0) + "px");
    c.style.setProperty("--mr", (Math.random() * 40 - 20).toFixed(0) + "deg");
    c.style.setProperty("--delay", (Math.random() * 0.45).toFixed(2) + "s");
  });
  tablero.classList.remove("repartida");
  tablero.classList.add("mezclando");
  setTimeout(() => {
    tablero.classList.remove("mezclando");
    tablero.classList.add("repartida");
  }, 1600);
}

function elegirCarta(indice) {
  if (bloqueado) return;
  const cartaDOM = $("tablero").children[indice];
  if (cartaDOM.classList.contains("volteada")) return;
  if (cartasUsadas >= MAX_CARTAS) return;

  indiceCartaActual = indice;
  const carta = cartas[indice];
  cartasUsadas++;
  $("contador-cartas").textContent = cartasUsadas;
  $("chip-carta").textContent = "Carta " + cartasUsadas + " de " + MAX_CARTAS;
  $("texto-pregunta").textContent = carta.pregunta;
  $("feedback").className = "feedback";

  const cont = $("opciones");
  cont.innerHTML = "";
  carta.opciones.forEach((texto, i) => {
    const btn = document.createElement("button");
    btn.className = "opcion";
    btn.textContent = texto;
    btn.addEventListener("click", () => responder(i));
    cont.appendChild(btn);
  });

  $("modal-pregunta").classList.remove("oculto");
}

function responder(indiceOpcion) {
  if (bloqueado) return;
  bloqueado = true;

  const carta = cartas[indiceCartaActual];
  const cartaDOM = $("tablero").children[indiceCartaActual];
  const botones = [...$("opciones").children];

  botones.forEach((b) => (b.disabled = true));
  botones[carta.correcta].classList.add("correcta");
  if (indiceOpcion !== carta.correcta) {
    botones[indiceOpcion].classList.add("incorrecta");
  }

  const feedback = $("feedback");
  const esCorrecta = indiceOpcion === carta.correcta;

  if (esCorrecta) {
    aciertos++;
    $("contador-aciertos").textContent = aciertos;
    cartaDOM.classList.add("correcta");
    feedback.textContent = "¡Correcto! " + carta.dato;
    feedback.className = "feedback visible ok";
  } else {
    cartaDOM.classList.add("incorrecta");
    feedback.textContent = "Uy, casi. " + carta.dato;
    feedback.className = "feedback visible mal";
  }

  setTimeout(() => {
    $("modal-pregunta").classList.add("oculto");
    cartaDOM.classList.add("volteada");
    bloqueado = false;

    if (aciertos >= ACIERTOS_PARA_GANAR) {
      finalizar(true);
    } else if (cartasUsadas >= MAX_CARTAS) {
      finalizar(false);
    } else if (aciertos === ACIERTOS_PARA_GANAR - 1) {
      $("texto-ayuda").textContent = "¡Te falta solo 1 acierto! Elige bien tu próxima carta";
    } else {
      const restantes = MAX_CARTAS - cartasUsadas;
      $("texto-ayuda").textContent = "Te quedan " + restantes + (restantes === 1 ? " carta" : " cartas") + " para lograr " + (ACIERTOS_PARA_GANAR - aciertos) + " acierto(s) más";
    }
  }, 1900);
}

function finalizar(gano) {
  bloqueado = true;
  const tarjeta = document.querySelector(".tarjeta-final");
  tarjeta.classList.remove("gano", "perdio");

  if (gano) {
    tarjeta.classList.add("gano");
    $("icono-final").textContent = "★";
    $("titulo-final").textContent = "¡GANASTE, GUARDIÁN DEL BARRIO!";
    $("mensaje-final").textContent =
      "Acertaste " + aciertos + " preguntas y demostraste que conoces MI BARRIO SEGURO como un verdadero vecino protector. Tu barrio está más seguro contigo.";
    lanzarConfeti();
  } else {
    tarjeta.classList.add("perdio");
    $("icono-final").textContent = "♥";
    $("titulo-final").textContent = "¡Buen intento, vecino!";
    $("mensaje-final").textContent =
      "Esta vez no llegaron los 3 aciertos, pero ya conoces mucho mejor MI BARRIO SEGURO, y eso también protege a tu comunidad. El barrio confía en ti: inténtalo otra vez, ¡la próxima seguro sale!";
  }

  $("estadisticas-final").innerHTML = `
    <div class="dato-final"><div class="numero">${aciertos}</div><div class="etiqueta">Aciertos</div></div>
    <div class="dato-final"><div class="numero">${cartasUsadas}</div><div class="etiqueta">Cartas jugadas</div></div>
    <div class="dato-final"><div class="numero">${MAX_CARTAS - cartasUsadas}</div><div class="etiqueta">Cartas sin usar</div></div>
  `;

  setTimeout(() => mostrarPantalla("pantalla-final"), 600);
}

function reiniciar() {
  $("confeti").classList.remove("activo");
  iniciarJuego();
}

function lanzarConfeti() {
  const canvas = $("confeti");
  const ctx = canvas.getContext("2d");
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  canvas.classList.add("activo");

  const colores = ["#f5b52e", "#ffd166", "#2ecc8f", "#e5484d", "#9aa5b8", "#ffffff"];
  const particulas = Array.from({ length: 160 }, () => ({
    x: Math.random() * canvas.width,
    y: -20 - Math.random() * canvas.height * 0.5,
    w: 6 + Math.random() * 7,
    h: 8 + Math.random() * 8,
    vel: 2 + Math.random() * 3.5,
    giro: Math.random() * Math.PI,
    velGiro: (Math.random() - 0.5) * 0.25,
    color: colores[Math.floor(Math.random() * colores.length)]
  }));

  const inicio = performance.now();

  function cuadro(ahora) {
    const transcurrido = ahora - inicio;
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    particulas.forEach((p) => {
      p.y += p.vel;
      p.giro += p.velGiro;
      ctx.save();
      ctx.translate(p.x, p.y);
      ctx.rotate(p.giro);
      ctx.fillStyle = p.color;
      ctx.globalAlpha = Math.max(0, 1 - transcurrido / 5200);
      ctx.fillRect(-p.w / 2, -p.h / 2, p.w, p.h);
      ctx.restore();
    });
    if (transcurrido < 5200) {
      requestAnimationFrame(cuadro);
    } else {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      canvas.classList.remove("activo");
    }
  }
  requestAnimationFrame(cuadro);
}

$("btn-jugar").addEventListener("click", iniciarJuego);
$("btn-reiniciar").addEventListener("click", reiniciar);
$("modal-pregunta").addEventListener("click", (e) => {
  if (e.target === $("modal-pregunta") && !bloqueado) {
    $("modal-pregunta").classList.add("oculto");
    cartasUsadas--;
    $("contador-cartas").textContent = cartasUsadas;
  }
});
