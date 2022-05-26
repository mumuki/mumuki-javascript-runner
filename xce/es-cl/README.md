### Preparación del entorno

Para poder resolver estos ejercicios, necesitarás utilizar los comandos `node` y `npm`. Antes de comenzar, asegúrate de tenerlos instalados. Luego, ejecuta el siguiente comando, por única vez:


```shell
npm install -g mumuki-xce
```
¡Ya puedes empezar a resolver ejercicios!

### Resolución de un ejercicio

Crea un archivo con extensión `.js` en tu computadora y copia el siguiente código dentro de éste:

```javascript
const Mumuki = require('./mumuki');
const mumuki = new Mumuki("/*...token...*/", "/*...locale...*/");
mumuki.visit("/*...organization...*/", "/*...exercise_id...*/");

// escribe tu solución aquí

mumuki.test();
```

Si deseas enviar tu solución, simplemente ejecuta en tu terminal lo siguiente:

```bash
node tuArchivo.js
```

Si en cambio deseas cargar tu archivo en el intérprete de `node` para probarlo y jugar con sus funciones antes de enviarlas, ejecuta lo siguiente:

```bash
node -i -e "$(< tuArchivo.js)"
```

¡Buena suerte!
