# fabio-skills

<p align="center">
  <img src="assets/cover.png" alt="Fabio" width="320">
</p>

Tre skill per agenti AI per avere Fabio sempre a portata di chat.

| Skill | Comando | Cosa fa |
| --- | --- | --- |
| [`fabio`](skills/fabio/SKILL.md) | `/fabio` | Parli direttamente con Fabio, di qualsiasi argomento: risponde in prima persona con la sua personalità, pregi e difetti compresi. |
| [`fabio-economic`](skills/fabio-economic/SKILL.md) | `/fabio-economic` | Fabio ti dice una delle sue "verità" economiche da bar, una frase sola. |
| [`fabio-poet`](skills/fabio-poet/SKILL.md) | `/fabio-poet` | Fabio "il poeta" ti dice un proverbio, una frase fatta, una similitudine o una metafora, spesso adattati a modo suo. |

Seguono lo standard `SKILL.md`, quindi funzionano con Claude (Code, app desktop e web), ChatGPT e gli altri agenti che supportano le skill.

## Installazione

Puoi installare Fabio completo (tutte e tre le skill) oppure solo `fabio-economic` o solo `fabio-poet`. Scegli il metodo in base a dove usi l'AI:

- [Da terminale](#da-terminale-cli): Claude Code, Codex, Cursor, Windsurf e gli altri agenti da riga di comando.
- [App Claude](#app-claude-desktop-e-web): app desktop e claude.ai, senza terminale.
- [ChatGPT](#chatgpt): app desktop, web e mobile.

### Da terminale (CLI)

Fabio completo, cioè `/fabio` insieme a `/fabio-economic` e `/fabio-poet`:

```bash
npx skills add fabio-giacomoni/fabio-skills --skill fabio --skill fabio-economic --skill fabio-poet -g -a claude-code
```

Solo le verità economiche:

```bash
npx skills add fabio-giacomoni/fabio-skills --skill fabio-economic -g -a claude-code
```

Solo i proverbi del poeta:

```bash
npx skills add fabio-giacomoni/fabio-skills --skill fabio-poet -g -a claude-code
```

Opzioni:

- `-a claude-code` installa per Claude Code; con `-a '*'` installi per tutti gli agenti supportati (Codex, Cursor, Windsurf, ...).
- `-g` rende le skill disponibili in tutte le chat; senza, vengono installate solo nel progetto corrente.

In alternativa, a mano: copia le cartelle che ti interessano da `skills/` dentro `~/.claude/skills/` (o `.claude/skills/` nel progetto).

### App Claude (desktop e web)

Nell'app Claude e su claude.ai le skill non si installano da terminale: si caricano direttamente come file ZIP, uno per skill.

**1. Scarica gli ZIP** dal repository [fabio-giacomoni/fabio-skills](https://github.com/fabio-giacomoni/fabio-skills). Clicca sul nome per scaricare il file:

| File | Skill | Serve per |
| --- | --- | --- |
| [`fabio.zip`](https://github.com/fabio-giacomoni/fabio-skills/raw/main/dist/fabio.zip) | `/fabio` | parlare con Fabio |
| [`fabio-economic.zip`](https://github.com/fabio-giacomoni/fabio-skills/raw/main/dist/fabio-economic.zip) | `/fabio-economic` | le verità economiche |
| [`fabio-poet.zip`](https://github.com/fabio-giacomoni/fabio-skills/raw/main/dist/fabio-poet.zip) | `/fabio-poet` | i proverbi del poeta |

Per Fabio completo scaricali tutti e tre; altrimenti solo quello che ti interessa. In alternativa apri la cartella [`dist/`](https://github.com/fabio-giacomoni/fabio-skills/tree/main/dist) del repository, clicca sul file e poi sull'icona **Download raw file**.

Non estrarre gli ZIP: vanno caricati così come sono.

**2. Carica gli ZIP su Claude**

1. Apri le impostazioni e cerca la sezione **Skills** (a seconda della versione si trova sotto *Personalizza* / *Customize* oppure *Funzionalità* / *Capabilities*).
2. Verifica che l'esecuzione di codice e la creazione di file siano attive: le skill ne hanno bisogno.
3. Clicca sul pulsante per caricare una skill e seleziona uno ZIP; ripeti per ogni ZIP scaricato.
4. Controlla che le skill caricate siano attive.

**3. Parla con Fabio**: in una nuova chat scrivi "fammi parlare con Fabio", oppure `/fabio`.

### ChatGPT

**Con le Skills di ChatGPT** (disponibili solo su alcuni piani e se abilitate nel tuo workspace):

1. Apri la sezione **Skills** (a seconda della versione si trova nel menu laterale o sotto *Plugins*).
2. Scegli **Create → Upload from your computer** e seleziona uno degli ZIP scaricati come spiegato [qui sopra](#app-claude-desktop-e-web); ripeti per ogni skill.
3. In una nuova chat scrivi "fammi parlare con Fabio".

**Senza Skills** (funziona su qualsiasi piano che abbia i Progetti o i GPT personalizzati):

1. Crea un **Progetto** oppure un **GPT personalizzato** e chiamalo "Fabio".
2. Nelle istruzioni incolla tutto il contenuto di [`skills/fabio/SKILL.md`](skills/fabio/SKILL.md).
3. Carica come file [`skills/fabio/profilo.md`](skills/fabio/profilo.md) e, per avere Fabio completo, anche [`skills/fabio-economic/SKILL.md`](skills/fabio-economic/SKILL.md) e [`skills/fabio-poet/SKILL.md`](skills/fabio-poet/SKILL.md). Hanno lo stesso nome: rinominali prima di caricarli, ad esempio `fabio-economic.md` e `fabio-poet.md`.
4. Apri una chat in quel Progetto o con quel GPT: stai già parlando con Fabio, senza bisogno di comandi.

Per avere solo le verità economiche o solo i proverbi, fai lo stesso incollando nelle istruzioni il solo `SKILL.md` di quella skill.

I nomi dei menu delle app cambiano spesso: se non trovi una voce, cerca "Skills" nelle impostazioni.

## Uso

### `/fabio`: parla con Fabio

Scrivi `/fabio` seguito da quello che vuoi dirgli, oppure chiedi "fammi parlare con Fabio":

```
/fabio secondo te conviene comprare la macchina nuova o usata?
```

Da quel momento l'agente è Fabio e puoi parlargli di qualsiasi cosa. Le risposte seguono rigorosamente il suo [profilo](skills/fabio/profilo.md):

- **chi è**: un ragazzo over 35 con una mentalità giovanile e aperta, nato, cresciuto e residente in provincia di Vicenza;
- **i pregi**: razionale e concreto, ironico e autoironico, empatico e contento di essere d'aiuto, "poeta" tra modi di dire e aneddoti, con una vena di saggezza e filosofia spicciola;
- **le competenze**: risponde da esperto sulle cose che lo appassionano: viaggi, calcio (da tifoso dell'Inter) e sport, natura e attività all'aria aperta, tecnologia, informatica e programmazione, edilizia, ristrutturazioni e fai da te;
- **il carattere**: calmo, gentile e rispettoso, non alza mai il tono; se lo insulti ti risponde con una battuta tagliente e indifferente, ma mai offensiva;
- **i difetti**: razionalizza le emozioni, rimanda le decisioni per pensarci ancora, non si scopre, usa la battuta come scudo, sopporta poco l'approssimazione e ogni tanto divaga;
- **le verità economiche**: ogni tanto, a caso, ne lascia cadere una nel mezzo del discorso, come fa lui;
- **i proverbi del poeta**: ogni tanto rafforza un concetto con un proverbio, una frase fatta, una similitudine o una metafora, spesso variati in base al discorso.

Resta nel personaggio finché non gli dici di smettere ("basta Fabio", "torna normale") oppure finché non apri una nuova chat.

È una simulazione basata su un profilo della personalità: non è Fabio in persona e gli aneddoti che racconta sono inventati.

### `/fabio-economic`: le verità economiche

Scrivi `/fabio-economic` e ricevi una frase, nient'altro:

> Il reparto pescheria di un supermercato è sempre in perdita economica.

Puoi anche indicare un argomento:

```
/fabio-economic palestre
```

Ogni volta la frase cambia: di solito è inventata sul momento con la stessa vibe, ogni tanto è una di quelle originali.

### `/fabio-poet`: i proverbi del poeta

Scrivi `/fabio-poet` e ricevi una frase, nient'altro:

> Tra il dire e il fare c'è di mezzo il preventivo.

Puoi indicare un argomento o una situazione, e la frase viene adattata:

```
/fabio-poet il mio capo rimanda sempre tutto
```

Può essere un proverbio classico, un proverbio variato, una similitudine o una metafora.

## Aggiornamento

Le skill installate sono una copia dei file al momento dell'installazione: non si aggiornano da sole. Quando esce una nuova versione vanno aggiornate, in modo diverso a seconda di dove le usi.

### Capire se c'è una nuova versione

Ogni versione pubblicata ha un tag su GitHub, ad esempio `v1.0.0`. L'elenco, con la più recente in alto, è nella pagina dei [tag del repository](https://github.com/fabio-giacomoni/fabio-skills/tags).

Per sapere quale versione hai installato, guarda il file `manifest.json` che si trova dentro ogni skill (e dentro ogni ZIP):

```json
{
  "name": "fabio",
  "version": "1.0.0",
  "tag": "v1.0.0",
  "repository": "https://github.com/fabio-giacomoni/fabio-skills",
  "updates": "https://github.com/fabio-giacomoni/fabio-skills/tags"
}
```

Se il `tag` del tuo manifest è più vecchio dell'ultimo tag su GitHub, c'è una nuova versione. Dove trovare il manifest:

- **Da terminale**: `cat ~/.claude/skills/fabio/manifest.json` (o `.claude/skills/fabio/manifest.json` se hai installato nel progetto).
- **App Claude e ChatGPT**: apri lo ZIP che avevi caricato, oppure il file `manifest.json` tra i file della skill nelle impostazioni.

### Da terminale (CLI)

```bash
npx skills check     # dice se ci sono aggiornamenti, senza installare nulla
npx skills update    # scarica e installa le nuove versioni
```

Se avevi copiato le cartelle a mano, ricopiale da `skills/`.

### App Claude (desktop e web)

1. Scarica di nuovo gli ZIP dalla tabella in [App Claude](#app-claude-desktop-e-web): i link puntano sempre all'ultima versione.
2. Nella sezione **Skills** delle impostazioni carica i nuovi ZIP al posto di quelli vecchi. Se l'app non permette di sostituirli, elimina prima la skill vecchia e poi carica quella nuova.

### ChatGPT

- **Con le Skills**: come per l'app Claude, scarica i nuovi ZIP e ricaricali.
- **Con un Progetto o un GPT personalizzato**: incolla di nuovo nelle istruzioni il contenuto aggiornato di `SKILL.md` e sostituisci i file caricati.

## Struttura

```
VERSION                   # numero di versione, es. 1.0.0 (tag git v1.0.0)
build.sh                  # scrive i manifest e rigenera gli ZIP in dist/
assets/
└── cover.png             # immagine di copertina
dist/                     # ZIP pronti da caricare nelle app, con il tag nel nome
├── fabio.zip
├── fabio-economic.zip
└── fabio-poet.zip
skills/
├── fabio/
│   ├── SKILL.md          # istruzioni per interpretare Fabio
│   ├── profilo.md        # profilo della personalità di Fabio
│   └── manifest.json     # versione e tag (generato da build.sh)
├── fabio-economic/
│   ├── SKILL.md          # ricetta ed esempi delle verità economiche
│   └── manifest.json
└── fabio-poet/
    ├── SKILL.md          # ricetta ed esempi di proverbi, similitudini e metafore
    └── manifest.json
```

## Modificare le skill

- **Personalità**: il carattere di Fabio è descritto in [`skills/fabio/profilo.md`](skills/fabio/profilo.md); il modo di parlare, i difetti da mostrare e i limiti sono in [`skills/fabio/SKILL.md`](skills/fabio/SKILL.md).
- **Verità economiche**: tutto è in [`skills/fabio-economic/SKILL.md`](skills/fabio-economic/SKILL.md). Per aggiungere frasi basta aggiungerle alla lista `## Esempi`: il modello le usa come base e ne inventa di nuove con la stessa vibe.
- **Proverbi del poeta**: tutto è in [`skills/fabio-poet/SKILL.md`](skills/fabio-poet/SKILL.md), con la stessa logica: ricetta più lista `## Esempi`.

## Pubblicare

Ogni pubblicazione ha un numero di versione, scritto nel file `VERSION`, a cui corrisponde un tag git con la `v` davanti (`1.1.0` → `v1.1.0`). Gli utenti confrontano quel tag con il loro `manifest.json` per sapere se devono aggiornare.

1. Modifica le skill.
2. Lancia il build con `--release` e la nuova versione:
   ```bash
   ./build.sh --release 1.1.0
   ```
   Al posto del numero puoi scrivere `patch`, `minor` o `major` per aumentare la cifra corrispondente della versione attuale (da `1.0.0`: `1.0.1`, `1.1.0`, `2.0.0`).

   Lo script aggiorna `VERSION`, scrive `manifest.json` in ogni skill, rigenera gli ZIP in `dist/` con il tag nel nome (`fabio-v1.1.0.zip`), rimuove quelli della versione precedente e aggiorna i link agli ZIP in questo README. Se il tag esiste già o una skill non è valida si ferma senza toccare `VERSION`.
3. Fai commit di tutto, crea il tag e pubblica. Lo script non esegue nessun comando git: alla fine stampa in evidenza i comandi con la versione giusta, da lanciare a mano:
   ```bash
   git add -A && git commit -m "Versione 1.1.0"
   git tag v1.1.0 && git push && git push origin v1.1.0
   ```

`--release` è facoltativo: in alternativa puoi aumentare a mano il numero nel file `VERSION` e lanciare `./build.sh` senza parametri, che rigenera manifest e ZIP con quella versione e stampa gli stessi comandi.

Lo script è in bash e richiede il comando `zip` (su Debian/Ubuntu: `sudo apt install zip`). Crea uno ZIP per ogni cartella di `skills/` (quindi anche per le skill aggiunte in futuro), verifica che ogni `SKILL.md` abbia `name` e `description` validi e rimuove gli ZIP delle versioni precedenti e delle skill eliminate. I nomi degli ZIP citati in questo README (link di download compresi) vengono riscritti a ogni build con il tag corrente: non serve correggerli a mano. Se il tag della versione in `VERSION` esiste già, avvisa che il numero va aumentato.

I file `manifest.json` sono generati: non modificarli a mano.

Per controllare soltanto che manifest e ZIP siano aggiornati, senza scrivere nulla:

```bash
./build.sh --check
```
