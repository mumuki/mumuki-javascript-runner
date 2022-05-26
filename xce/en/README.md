### Setup instructions

You will need to have `node` and `npm` installed
in your computer. Then, run the following command:

```shell
npm install -g mumuki-xce
```
Now you are ready to start.

### Running an exercise

Just create a new javascript file, and past the following
code:

```javascript
const Mumuki = require('./mumuki');
const mumuki = new Mumuki("/*...token...*/", "/*...locale...*/");
mumuki.visit("/*...organization...*/", "/*...exercise_id...*/");

// place your solution here

mumuki.test();
```

If you want to submit your solution, just run on your terminal

```bash
node yourFile.js
```

If you just want to load it into a node interpreter and test and play
with your code, run:

```bash
node -i -e "$(< yourFile.js)"
```