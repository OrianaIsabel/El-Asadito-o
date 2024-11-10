class Comensal {
  const elementosCercanos
  var posicion
  var criterioParaPasar
  var criterioParaComer
  const queHaComido = []

  method elementosCercanos() = elementosCercanos
  method posicion() = posicion
  method queHaComido() = queHaComido

  method eliminarElementos(elementos) {
    elementos.forEach({elemento => elementosCercanos.remove(elemento)})
  }

  method agregarElementos(elementos) {
    elementos.forEach({elemento => elementosCercanos.add(elemento)})
  }

  method cambiarPosicion(nuevaPosicion) {
    posicion = nuevaPosicion
  }

  method cambiarCriterioParaPasar(nuevoCriterio) {
    criterioParaPasar = nuevoCriterio
  }

  method pasarIngrediente(elemento, persona) {
    if (elementosCercanos.contains(elemento)) 
    criterioParaPasar.cambioDeIngredientes(elemento, self, persona)
  }

  method pedirIngrediente(elemento, persona) {
    persona.pasarIngrediente(elemento, self)
  }

  method cambiarCriterioParaComer(nuevoCriterio) {
    criterioParaComer = nuevoCriterio
  }

  method quiereComer(comida) = criterioParaComer.acepta(comida)

  method Comer(comida) {
    if (self.quiereComer(comida)) queHaComido.add(comida)
  }

  method estaPipon() = queHaComido.any({comida => comida.calorias() > 500})

  method laEstaPasandoBien() = !(queHaComido.isEmpty())
}


// Criterios para pasar

class CriterioParaPasar {
  method cambioDeIngredientes(elemento, quienPasa, quienPide)

  method intercambio(elementos, quienPasa, quienPide) {
    quienPasa.eliminarElementos(elementos)
    quienPide.agregarElementos(elementos)
  }
}

object sordera inherits CriterioParaPasar {
  override method cambioDeIngredientes(elemento, quienPasa, quienPide) {
    self.intercambio(quienPasa.elementosCercanos().take(1), quienPasa, quienPide)
  }
}

object pasarTodo inherits CriterioParaPasar {
  override method cambioDeIngredientes(elemento, quienPasa, quienPide) {
    self.intercambio(quienPasa.elementosCercanos(), quienPasa, quienPide)
  }
}

object quererOtraPosicion inherits CriterioParaPasar {
  override method cambioDeIngredientes(elemento, quienPasa, quienPide) {
    self.intercambio(elemento, quienPasa, quienPide)
    const posicion1 = quienPasa.posicion()
    quienPasa.cambiarPosicion(quienPide.posicion())
    quienPide.cambiarPosicion(quienPasa.posicion())
  }
}

object pasarNormalmente inherits CriterioParaPasar {
  override method cambioDeIngredientes(elemento, quienPasa, quienPide) {
    self.intercambio(elemento, quienPasa, quienPide)
  }
}


// Criterios para comer

class Comida {
  const calorias
  const esCarne

  method calorias() = calorias
  method esCarne() = esCarne
}

class CriterioParaComer {
  method acepta(comida)
}

object vegetariano inherits CriterioParaComer {
  override method acepta(comida) = !(comida.esCarne())
}

class Dietetico inherits CriterioParaComer {
  const caloriasAceptadas = 500
  override method acepta(comida) = comida.calorias() < caloriasAceptadas
}

class Alternado inherits CriterioParaComer {
  const comidaOfrecida = []
  override method acepta(comida) {
    comidaOfrecida.add(comida)
    return comidaOfrecida.size().odd()
  }
}

class Combinado inherits CriterioParaComer {
  const dietetico = new Dietetico()
  const alternado = new Alternado()
  override method acepta(comida) = vegetariano.acepta(comida) && dietetico.acepta(comida) && alternado.acepta(comida) 
}


// Comensales

object obsky inherits Comensal (posicion = 4, criterioParaPasar = pasarNormalmente, criterioParaComer = new Combinado(), elementosCercanos = [pan, mayonesa]) {
  override method laEstaPasandoBien() = true
}

object facu inherits Comensal (posicion = 1, criterioParaPasar = sordera, criterioParaComer = new Alternado(), elementosCercanos = [pimienta, sal]) {
  override method laEstaPasandoBien() = super() && queHaComido.any({comida => comida.esCarne()})
}

object moni inherits Comensal (posicion = 3, criterioParaPasar = quererOtraPosicion, criterioParaComer = new Dietetico(caloriasAceptadas = 300), elementosCercanos = [mostaza]) {
  override method laEstaPasandoBien() = super() && (posicion == 1)
}

object vero inherits Comensal (posicion = 2, criterioParaPasar = pasarTodo, criterioParaComer = vegetariano, elementosCercanos = [mostaza]) {
  override method laEstaPasandoBien() = super() && (elementosCercanos.size() < 3)
}

object pimienta {}
object sal {}
object mostaza {}
object pan {}
object mayonesa {}

const papa = new Comida(calorias = 400, esCarne = false)