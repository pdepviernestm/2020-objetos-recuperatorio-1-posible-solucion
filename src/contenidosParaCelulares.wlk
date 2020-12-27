// El calendario, hoyreal y hoyfalso no era necesario que lo modelen, yo lo agregué para poder testear casos en los que necesito
// "viajar en el tiempo", pero no se evaluaba eso porque es un poco más avanzado que lo que damos en clase de testeo
// con que en el examen hubiesen puesto new Date() en donde se necesitaba la fecha actual se contaba como bien
class HoyFalso { // esta clase solo se usa para los tests
	const property fecha
}

object hoyReal {
	method fecha() = new Date()
}

object calendario {
	var property hoy = hoyReal
	method fecha() = hoy.fecha()
}

object empresaDeComercializacionDeContenidos {
	const descargas = []
	var property costoPorCaracterEnChistes = 0
	
	method cuantoCobraPorDescarga(montoBase) = montoBase * 0.25

	method registrarDescarga(unCliente, unProducto, unPrecio) {
		const descarga = new Descarga(producto = unProducto, cliente = unCliente, gasto = unPrecio, fechaDeDescarga = calendario.fecha())
		descargas.add(descarga)
	}
	
	method cuantoGastoEnElMesActual(cliente) {
		const descargasDelMes = self.descargasDelMes(descargas)
		const descargasDelClienteEnElMes = self.descargasDeCliente(descargasDelMes, cliente)
		
		return descargasDelClienteEnElMes.sum { descarga => descarga.gasto() }	
	}

	method esColgado(cliente) {
		const descargasDelCliente = self.descargasDeCliente(descargas, cliente)
		const productosDelCliente = self.productosDe(descargasDelCliente)

		return productosDelCliente.withoutDuplicates() != productosDelCliente
	}
	
	method productoMasDescargado(fecha) {
		const descargasDeEsaFecha = self.descargasDeFecha(descargas, fecha)
		const productosDescargados = self.productosDe(descargasDeEsaFecha)

		return productosDescargados.max { producto => productosDescargados.occurrencesOf(producto) }
	}
	
	method productosDe(unasDescargas) = unasDescargas.map { descarga => descarga.producto() }
	method descargasDeCliente(unasDescargas, cliente) = unasDescargas.filter { descarga => descarga.esDe(cliente) }
	method descargasDeFecha(unasDescargas, unaFecha) = unasDescargas.filter { descarga => descarga.esDeFecha(unaFecha) }
	method descargasDelMes(unasDescargas) = unasDescargas.filter { descarga => descarga.esDeMismoMesQue(calendario.fecha()) }
}



// DESCARGAS

class Descarga {
	const cliente
	const fechaDeDescarga
	const property producto
	const property gasto 
	
	method esDe(unCliente) = cliente == unCliente
	
	method esDeMismoMesQue(unaFecha) {
		return unaFecha.year() == fechaDeDescarga.year() && unaFecha.month() == fechaDeDescarga.month()
	}
	
	method esDeFecha(fecha) = fechaDeDescarga == fecha
}



// CLIENTES

class Cliente {
	var plan
	const companiaDeTelecomunicaciones

	method precioDeDescarga(producto, empresaDeComercializacionDeContenidos) {
		const montoPorDerechoDeAutor = producto.montoPorDerechoDeAutor(empresaDeComercializacionDeContenidos)

		const precio = montoPorDerechoDeAutor +
						companiaDeTelecomunicaciones.cuantoCobraPorDescarga(montoPorDerechoDeAutor) +
						empresaDeComercializacionDeContenidos.cuantoCobraPorDescarga(montoPorDerechoDeAutor)

		return precio + plan.cuantoCobraPorDescarga(precio)
	}
	
	method descargar(producto, empresaDeComercializacion) {
		const precio = self.precioDeDescarga(producto, empresaDeComercializacion)

		plan.realizarDescargaDe(precio)
		
		empresaDeComercializacion.registrarDescarga(self, producto, precio)
	}
	
	method cuantoGastoEnElMesActualCon(empresaDeComercializacionDeContenidos) =
		empresaDeComercializacionDeContenidos.cuantoGastoEnElMesActual(self)
		
	method esColgadoPara(empresaDeComercializacionDeContenidos) = 
		empresaDeComercializacionDeContenidos.esColgado(self)
}



// COMPANIAS

class CompaniaDeTelecomunicacionesNacional {
	method cuantoCobraPorDescarga(montoBase) = montoBase * 0.05
}

object impuestoPorPrestacion {
	var property valor = 0
}

class CompaniaDeTelecomunicacionesExtranjera {
	method cuantoCobraPorDescarga(montoBase) =
		new CompaniaDeTelecomunicacionesNacional().cuantoCobraPorDescarga(montoBase) + impuestoPorPrestacion.valor()
}


// PRODUCTOS

class Ringtone {
	const duracionEnMinutos 
	const autor
	
	method montoPorDerechoDeAutor(empresaDeComercializacionDeContenidos) = duracionEnMinutos * self.precioPorMinuto()

	method precioPorMinuto() = autor.precioPorMinuto()
}

class Autor {
	const property precioPorMinuto
}

class Chiste {
	const chiste
	
	method montoPorDerechoDeAutor(empresaDeComercializacionDeContenidos) =
		empresaDeComercializacionDeContenidos.costoPorCaracterEnChistes() * self.cantidadDeCaracteres()
	
	method cantidadDeCaracteres() = chiste.size()
	
}

class Juego {
	const monto
	
	method montoPorDerechoDeAutor(empresaDeComercializacionDeContenidos) = monto
}

// PLANES

class Plan {
	method realizarDescargaDe(precio) {
		self.validarQueSePuedePagarDescarga(precio)
		self.pagarDescarga(precio)
	}
	
	method validarQueSePuedePagarDescarga(precio)
	
	method pagarDescarga(precio)
}

class Prepago inherits Plan {
	var property saldo
	
	method cuantoCobraPorDescarga(precio) = precio * 0.1
	
	override method validarQueSePuedePagarDescarga(precio) {
		if (saldo < precio) {
			self.error("El cliente no posee suficiente saldo para descargar el producto. Tiene " + saldo.toString() + " y necesita " + precio.toString())
		}
	}
	
	override method pagarDescarga(precio) {
		saldo -= precio
	}
}

class Facturado inherits Plan {
	var property montoGastado = 0

	override method validarQueSePuedePagarDescarga(precio) {}

	method cuantoCobraPorDescarga(precio) = 0
	
	override method pagarDescarga(precio) {
		montoGastado += precio
	}
}
