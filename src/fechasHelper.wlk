import contenidosParaCelulares.*

// Objetos para ayudar en los tests que necesitan usar fechas
// Esto no era necesario hacerlo en el parcial, solo esta agregado para poder testear el tema de las fechas

object hacerEn {
	method fecha(unaFecha, accion) {
		calendario.hoy(new HoyFalso(fecha = unaFecha))
		
		accion.apply()
		
		calendario.hoy(hoyReal)
	}
	
}
