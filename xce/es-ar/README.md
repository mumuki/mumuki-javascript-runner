### Preparación del entorno

Para poder resolver estos ejercicios, necesitarás utilizar los comandos `node` y `npm`. Antes de comenzar, asegurate de tenerlos instalados. Después, ejecutá el siguiente comando, por única vez:


```shell
npm install -g mumuki-xce
```
¡Ya podés empezar a resolver ejercicios!

### Resolución de un ejercicio

Creá un archivo con extensión `.js` en tu computadora y adentro copiá el siguiente código:

```javascript
const Mumuki = require('./mumuki');
const mumuki = new Mumuki("/*...token...*/", "/*...locale...*/");
mumuki.visit("/*...organization...*/", "/*...exercise_id...*/");

// escribí tu solución acá

mumuki.test();
```

Si querés enviar tu solución, simplemente ejecutá en tu terminal lo siguiente:

```bash
node tuArchivo.js
```

Si en cambio querés cargar tu archivo en el intérprete de `node` para probarlo y jugar con sus funciones antes de enviarlas, ejecutá lo siguiente:

```bash
node -i -e "$(< tuArchivo.js)"
```

¡Éxitos!
