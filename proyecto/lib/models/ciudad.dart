import 'package:flutter/material.dart';

class CiudadEcuador {
  final String nombre;
  final String provincia;
  final int poblacion;
  final double altitud;
  final String descripcion;
  final IconData icono;
  final Color color;
  final List<String> atractivos;

  const CiudadEcuador({
    required this.nombre,
    required this.provincia,
    required this.poblacion,
    required this.altitud,
    required this.descripcion,
    required this.icono,
    required this.color,
    required this.atractivos,
  });
}

class CiudadesEcuadorData {
  static const List<CiudadEcuador> ciudades = [
    CiudadEcuador(
      nombre: 'Quito',
      provincia: 'Pichincha',
      poblacion: 2812000,
      altitud: 2850,
      descripcion:
          'Capital del Ecuador y Patrimonio Cultural de la Humanidad. Sede de la FIS-EPN.',
      icono: Icons.account_balance,
      color: Color(0xFF1A4D8F),
      atractivos: [
        'Mitad del Mundo',
        'TelefériQo',
        'Basílica del Voto Nacional',
        'Centro Histórico Colonial',
        'Panecillo',
      ],
    ),
    CiudadEcuador(
      nombre: 'Guayaquil',
      provincia: 'Guayas',
      poblacion: 2725000,
      altitud: 4,
      descripcion:
          'La Perla del Pacífico. Principal puerto del país y motor económico.',
      icono: Icons.directions_boat,
      color: Color(0xFFE63946),
      atractivos: [
        'Malecón 2000',
        'Cerro Santa Ana',
        'Las Peñas',
        'Parque Seminario',
        'Isla Santay',
      ],
    ),
    CiudadEcuador(
      nombre: 'Cuenca',
      provincia: 'Azuay',
      poblacion: 636000,
      altitud: 2560,
      descripcion:
          'Atenas del Ecuador. Ciudad Patrimonio Cultural de la Humanidad.',
      icono: Icons.church,
      color: Color(0xFF2A9D8F),
      atractivos: [
        'Catedral de la Inmaculada',
        'Parque Nacional Cajas',
        'Mirador de Turi',
        'Pumapungo',
        'Río Tomebamba',
      ],
    ),
    CiudadEcuador(
      nombre: 'Ambato',
      provincia: 'Tungurahua',
      poblacion: 387000,
      altitud: 2570,
      descripcion:
          'Jardín del Ecuador. Conocida por sus flores y frutas.',
      icono: Icons.local_florist,
      color: Color(0xFFF77F00),
      atractivos: [
        'Fiesta de las Flores',
        'Quinta de Juan Montalvo',
        'Parque Provincial de la Familia',
        'Avenida de las Madres',
        'Mirador de Bellavista',
      ],
    ),
    CiudadEcuador(
      nombre: 'Riobamba',
      provincia: 'Chimborazo',
      poblacion: 264000,
      altitud: 2750,
      descripcion:
          'Sultan de los Andes. Puerta de entrada al Volcán Chimborazo.',
      icono: Icons.landscape,
      color: Color(0xFF6A4C93),
      atractivos: [
        'Volcán Chimborazo',
        'Parque 21 de Abril',
        'Basílica del Sagrado Corazón',
        'Museo de la Ciudad',
        'Balbanera',
      ],
    ),
    CiudadEcuador(
      nombre: 'Loja',
      provincia: 'Loja',
      poblacion: 215000,
      altitud: 2060,
      descripcion:
          'Ciudad musical del Ecuador. Cuna de artistas y educadores.',
      icono: Icons.music_note,
      color: Color(0xFF457B9D),
      atractivos: [
        'Parque Nacional Podocarpus',
        'Católica de Loja',
        'Plaza de la Independencia',
        'Jipiro',
        'Mirador del Valle',
      ],
    ),
    CiudadEcuador(
      nombre: 'Esmeraldas',
      provincia: 'Esmeraldas',
      poblacion: 200000,
      altitud: 15,
      descripcion:
          'Provincia verde del Ecuador. Costas, marimba y cultura afro.',
      icono: Icons.waves,
      color: Color(0xFF06A77D),
      atractivos: [
        'Playa de Las Palmas',
        'Playa de Same',
        'Refugio de Vida Silvestre Muisne',
        'Cascada de San Miguel',
        'Malecón de Tonsupa',
      ],
    ),
    CiudadEcuador(
      nombre: 'Ibarra',
      provincia: 'Imbabura',
      poblacion: 175000,
      altitud: 2225,
      descripcion:
          'Ciudad Blanca. Capital de los Imbabura y de la Revolución Liberal.',
      icono: Icons.castle,
      color: Color(0xFFE9C46A),
      atractivos: [
        'Laguna de Yahuarcocha',
        'Cotacachi-Cayapas',
        'Centro Cultural Solanda',
        'Plaza de los Hermanos Cifuentes',
        'Mercado Amazonas',
      ],
    ),
  ];

  static CiudadEcuador byNombre(String nombre) {
    return ciudades.firstWhere(
      (c) => c.nombre.toLowerCase() == nombre.toLowerCase(),
      orElse: () => ciudades.first,
    );
  }
}
