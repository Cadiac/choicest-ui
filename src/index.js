import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const app = Main.embed(document.getElementById('root'), {
  apiUrl: process.env.ELM_APP_API_URL,
  token: localStorage.token || null,
});

app.ports.storeToken.subscribe((token) => {
  localStorage.token = token;
});

window.addEventListener('storage', (event) => {
  if (event.storageArea === localStorage && event.key === 'token') {
    app.ports.onTokenChange.send(event.newValue);
  }
}, false);


registerServiceWorker();
