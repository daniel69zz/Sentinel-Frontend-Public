import 'package:flutter/material.dart';

import '../../../core/localization/app_language_service.dart';
import '../domain/models/education_story_panel.dart';
import '../domain/models/education_topic.dart';

class EducationTopicsCatalog {
  static const String sampleVideoUrl =
      'https://samplelib.com/lib/preview/mp4/sample-5s.mp4';

  static List<EducationTopic> get topics {
    final l10n = AppLanguageService.instance;
    String t(String es, String en) => l10n.pick(es: es, en: en);

    return [
    EducationTopic(
      id: 'derechos-sexuales',
      icon: Icons.favorite_rounded,
      color: Color(0xFFD63864),
      title: t('Derechos Sexuales', 'Sexual Rights'),
      description: t(
        'Conoce tus derechos sexuales fundamentales y como ejercerlos libremente.',
        'Learn about your fundamental sexual rights and how to exercise them freely.',
      ),
      tag: t('Basico', 'Basic'),
      videoTitle: t('Video introductorio de ejemplo', 'Sample introduction video'),
      videoDescription: t(
        'Aqui despues podremos colocar un video corto para explicar este tema con ejemplos visuales.',
        'Later we can place a short video here to explain this topic with visual examples.',
      ),
      videoUrl: sampleVideoUrl,
      storyPanels: [
        EducationStoryPanel(
          eyebrow: 'Escena 01',
          title: 'Tu decision importa',
          caption:
              'Este panel deja espacio para una ilustracion grande donde se vea autonomia, escucha y respeto.',
          bubbleText: 'Mi cuerpo, mi voz y mi decision.',
          footer: 'Lugar ideal para una escena inicial de comic o infografia.',
          icon: Icons.person_pin_circle_rounded,
          color: Color(0xFFD63864),
        ),
        EducationStoryPanel(
          eyebrow: 'Escena 02',
          title: 'Consentimiento claro',
          caption:
              'Aqui puede ir una secuencia visual sencilla para mostrar acuerdos, limites y comunicacion.',
          bubbleText: 'Si no es claro, no hay consentimiento.',
          footer:
              'Espacio pensado para dibujos verticales, no carruseles laterales.',
          icon: Icons.record_voice_over_rounded,
          color: Color(0xFFE75A7C),
        ),
        EducationStoryPanel(
          eyebrow: 'Escena 03',
          title: 'Respeto y bienestar',
          caption:
              'En esta parte se puede cerrar con una ilustracion de apoyo mutuo y cuidado emocional.',
          bubbleText: 'El respeto tambien se ve y se siente.',
          footer:
              'Buen cierre para una mini historia visual antes del texto final.',
          icon: Icons.favorite_border_rounded,
          color: Color(0xFFC92F58),
        ),
      ],
      textBlocks: [
        'Aqui ira una explicacion sencilla sobre el tema, usando un lenguaje claro y cercano.',
        'Tambien podemos agregar ejemplos cotidianos, preguntas frecuentes y pequenas recomendaciones.',
        'Por ahora este bloque solo sirve para mostrar como se vera la informacion escrita al final.',
      ],
    ),
    EducationTopic(
      id: 'derechos-reproductivos',
      icon: Icons.child_care_rounded,
      color: Color(0xFF9C27B0),
      title: t('Derechos Reproductivos', 'Reproductive Rights'),
      description: t(
        'Informacion sobre planificacion familiar, anticoncepcion y salud reproductiva.',
        'Information about family planning, contraception and reproductive health.',
      ),
      tag: t('Importante', 'Important'),
      videoTitle: t('Video guia de ejemplo', 'Sample guide video'),
      videoDescription: t(
        'Este espacio puede mostrar una guia visual corta sobre decisiones reproductivas y acceso a informacion.',
        'This space can show a short visual guide about reproductive decisions and access to information.',
      ),
      videoUrl: sampleVideoUrl,
      storyPanels: [
        EducationStoryPanel(
          eyebrow: 'Escena 01',
          title: 'Proyecto de vida',
          caption:
              'Aqui puede ir una ilustracion central que muestre decisiones personales y acompanamiento.',
          bubbleText: 'Elegir tambien es un derecho.',
          footer:
              'Panel amplio para infografia con objetos, calendario o personajes.',
          icon: Icons.family_restroom_rounded,
          color: Color(0xFF9C27B0),
        ),
        EducationStoryPanel(
          eyebrow: 'Escena 02',
          title: 'Planificacion informada',
          caption:
              'Se puede usar esta zona para mostrar rutas, opciones y tiempos en una secuencia vertical.',
          bubbleText: 'Informarme me ayuda a decidir mejor.',
          footer: 'Espacio para viñetas o pasos visuales descendentes.',
          icon: Icons.calendar_month_rounded,
          color: Color(0xFFB146C2),
        ),
        EducationStoryPanel(
          eyebrow: 'Escena 03',
          title: 'Acceso a servicios',
          caption:
              'Este panel final puede mostrar centros de salud, apoyo y orientacion profesional.',
          bubbleText: 'Pedir ayuda tambien forma parte del cuidado.',
          footer: 'Cierre ideal antes de entrar a la informacion escrita.',
          icon: Icons.local_hospital_rounded,
          color: Color(0xFF7B1FA2),
        ),
      ],
      textBlocks: [
        'Luego podremos poner aqui informacion util sobre decisiones reproductivas, servicios y acompanamiento.',
        'Este bloque de ejemplo ayuda a validar el orden visual del contenido antes de cargar material real.',
        'Tambien se puede usar para resaltar enlaces, rutas de apoyo o pasos recomendados.',
      ],
    ),
    EducationTopic(
      id: 'prevencion-violencia',
      icon: Icons.shield_rounded,
      color: Color(0xFF2196F3),
      title: t('Prevencion de Violencia', 'Violence Prevention'),
      description: t(
        'Aprende a identificar senales de violencia sexual y de genero.',
        'Learn to identify signs of sexual and gender-based violence.',
      ),
      tag: t('Seguridad', 'Safety'),
      videoTitle: t('Video preventivo de ejemplo', 'Sample prevention video'),
      videoDescription: t(
        'Aqui podemos incluir un video breve para reconocer alertas tempranas y acciones de autocuidado.',
        'Here we can include a short video to recognize early warning signs and self-care actions.',
      ),
      videoUrl: sampleVideoUrl,
      storyPanels: [
        EducationStoryPanel(
          eyebrow: 'Escena 01',
          title: 'Reconocer senales',
          caption:
              'Este primer bloque puede mostrar indicadores visuales de control, amenaza o aislamiento.',
          bubbleText: 'Algo no se siente bien, vale la pena mirarlo.',
          footer:
              'Espacio vertical amplio para carteles, gestos y simbolos de alerta.',
          icon: Icons.visibility_rounded,
          color: Color(0xFF2196F3),
        ),
        EducationStoryPanel(
          eyebrow: 'Escena 02',
          title: 'Buscar apoyo',
          caption:
              'Aqui despues pueden ir personajes, redes de apoyo y acciones concretas para pedir ayuda.',
          bubbleText: 'No tengo que manejarlo sola.',
          footer: 'Buena seccion para una escena tipo comic con dialogo.',
          icon: Icons.support_agent_rounded,
          color: Color(0xFF42A5F5),
        ),
        EducationStoryPanel(
          eyebrow: 'Escena 03',
          title: 'Elegir una ruta segura',
          caption:
              'El cierre visual puede mostrar desplazamiento, salida y puntos de encuentro o resguardo.',
          bubbleText: 'Puedo moverme hacia un lugar mas seguro.',
          footer: 'Ultimo panel pensado para una bajada visual clara.',
          icon: Icons.map_rounded,
          color: Color(0xFF1976D2),
        ),
      ],
      textBlocks: [
        'Este espacio puede explicar como reconocer comportamientos de control, amenaza o aislamiento.',
        'Tambien puede resumir acciones concretas para protegerse y buscar apoyo sin exponerse mas.',
        'Por ahora el contenido es de demostracion para dejar la estructura lista.',
      ],
    ),
    EducationTopic(
      id: 'metodos-anticonceptivos',
      icon: Icons.medical_services_rounded,
      color: Color(0xFF4CAF50),
      title: t('Metodos Anticonceptivos', 'Contraceptive Methods'),
      description: t(
        'Guia completa sobre tipos, eficacia y acceso a metodos anticonceptivos en Bolivia.',
        'A complete guide to contraceptive types, effectiveness and access in Bolivia.',
      ),
      tag: t('Salud', 'Health'),
      videoTitle: t('Video comparativo de ejemplo', 'Sample comparison video'),
      videoDescription: t(
        'Mas adelante este bloque puede mostrar una explicacion visual sobre tipos y uso correcto de metodos.',
        'Later this block can show a visual explanation about method types and correct use.',
      ),
      videoUrl: sampleVideoUrl,
      storyPanels: [
        EducationStoryPanel(
          eyebrow: 'Escena 01',
          title: 'Panorama general',
          caption:
              'Aqui puede ir una ilustracion grande con categorias y opciones para una lectura visual rapida.',
          bubbleText: 'Hay varias opciones y cada una tiene algo distinto.',
          footer:
              'Espacio comodo para una primera viñeta o laminas informativas.',
          icon: Icons.medication_rounded,
          color: Color(0xFF4CAF50),
        ),
        EducationStoryPanel(
          eyebrow: 'Escena 02',
          title: 'Uso y frecuencia',
          caption:
              'En esta parte se puede mostrar como cambian el uso, el seguimiento y los cuidados.',
          bubbleText: 'Entender el uso correcto cambia mucho.',
          footer: 'Buen lugar para comparativas visuales en vertical.',
          icon: Icons.check_circle_outline_rounded,
          color: Color(0xFF66BB6A),
        ),
        EducationStoryPanel(
          eyebrow: 'Escena 03',
          title: 'Informacion segura',
          caption:
              'El ultimo panel puede mostrar orientacion medica, preguntas frecuentes y decisiones informadas.',
          bubbleText: 'La informacion confiable me da mas calma.',
          footer: 'Cierre preparado para conectar con el texto de abajo.',
          icon: Icons.info_outline_rounded,
          color: Color(0xFF388E3C),
        ),
      ],
      textBlocks: [
        'Aqui luego podemos colocar comparaciones breves entre opciones, ventajas y consideraciones importantes.',
        'Tambien es un buen espacio para aclarar mitos y reforzar decisiones informadas.',
        'De momento estos textos son solo de muestra para validar el diseno.',
      ],
    ),
    EducationTopic(
      id: 'riesgo',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFF57C00),
      title: t('Que hacer si estas en riesgo?', 'What to do if you are at risk?'),
      description: t(
        'Pasos a seguir si sientes que puedes ser victima de un ataque o violencia.',
        'Steps to follow if you feel you could become a victim of an attack or violence.',
      ),
      tag: t('Urgente', 'Urgent'),
      videoTitle: t('Video de respuesta rapida', 'Quick response video'),
      videoDescription: t(
        'Este ejemplo muestra donde ira un recurso visual con pasos inmediatos y faciles de recordar.',
        'This example shows where a visual resource with immediate and easy-to-remember steps will go.',
      ),
      videoUrl: sampleVideoUrl,
      storyPanels: [
        EducationStoryPanel(
          eyebrow: 'Escena 01',
          title: 'Avisar rapido',
          caption:
              'Esta primera escena puede mostrar un telefono, una red de apoyo o una alerta corta.',
          bubbleText: 'Necesito avisar ahora.',
          footer: 'Espacio amplio para un dibujo con accion inmediata.',
          icon: Icons.phone_in_talk_rounded,
          color: Color(0xFFF57C00),
        ),
        EducationStoryPanel(
          eyebrow: 'Escena 02',
          title: 'Moverte a un punto visible',
          caption:
              'Aqui se puede representar un desplazamiento claro hacia un lugar seguro o concurrido.',
          bubbleText: 'Voy hacia donde haya gente o apoyo.',
          footer: 'Ideal para una secuencia de movimiento en bajada.',
          icon: Icons.directions_walk_rounded,
          color: Color(0xFFFF9800),
        ),
        EducationStoryPanel(
          eyebrow: 'Escena 03',
          title: 'Reducir la exposicion',
          caption:
              'El ultimo panel puede resumir medidas simples para protegerse mientras llega ayuda.',
          bubbleText: 'Puedo ganar tiempo y cuidarme mejor.',
          footer: 'Buen remate visual antes de los pasos escritos.',
          icon: Icons.shield_moon_rounded,
          color: Color(0xFFEF6C00),
        ),
      ],
      textBlocks: [
        'Aqui podremos dejar una lista breve de pasos inmediatos, con lenguaje claro y accionable.',
        'Tambien servira para recordar numeros, contactos o recomendaciones que no requieran mucho tiempo de lectura.',
        'Por ahora este contenido sirve como maqueta funcional.',
      ],
    ),
    EducationTopic(
      id: 'despues',
      icon: Icons.healing_rounded,
      color: Color(0xFF00BCD4),
      title: t('Que hacer despues', 'What to do afterwards'),
      description: t(
        'Apoyo, recursos y pasos legales tras una situacion de violencia sexual.',
        'Support, resources and legal steps after a situation of sexual violence.',
      ),
      tag: t('Recuperacion', 'Recovery'),
      videoTitle: t(
        'Video de acompanamiento de ejemplo',
        'Sample support video',
      ),
      videoDescription: t(
        'Aqui ira un contenido visual enfocado en apoyo emocional, opciones disponibles y siguientes pasos.',
        'A visual resource focused on emotional support, available options and next steps will go here.',
      ),
      videoUrl: sampleVideoUrl,
      storyPanels: [
        EducationStoryPanel(
          eyebrow: 'Escena 01',
          title: 'Atencion inicial',
          caption:
              'Aqui puede ir una ilustracion amplia sobre cuidado medico, emocional y acompanamiento.',
          bubbleText: 'No tengo que pasar esto sola.',
          footer: 'Espacio pensado para una escena serena y clara.',
          icon: Icons.health_and_safety_rounded,
          color: Color(0xFF00BCD4),
        ),
        EducationStoryPanel(
          eyebrow: 'Escena 02',
          title: 'Orientacion y denuncia',
          caption:
              'Este panel puede mostrar la ruta legal o institucional de forma simple y visual.',
          bubbleText: 'Puedo pedir orientacion antes de decidir.',
          footer: 'Buena zona para una infografia legal resumida.',
          icon: Icons.gavel_rounded,
          color: Color(0xFF26C6DA),
        ),
        EducationStoryPanel(
          eyebrow: 'Escena 03',
          title: 'Seguimiento y red de apoyo',
          caption:
              'Cierre visual para mostrar acompanamiento continuo, descanso y redes seguras.',
          bubbleText: 'Recuperarme tambien merece tiempo y apoyo.',
          footer: 'Ultimo panel preparado para conectar con texto mas extenso.',
          icon: Icons.people_alt_rounded,
          color: Color(0xFF00ACC1),
        ),
      ],
      textBlocks: [
        'Este espacio despues puede reunir informacion de apoyo, recuperacion y acompanamiento institucional.',
        'Tambien podria incluir recordatorios para guardar evidencia y buscar ayuda profesional.',
        'Por el momento dejamos texto de ejemplo para que ya exista la estructura completa.',
      ],
    ),
    ];
  }
}
