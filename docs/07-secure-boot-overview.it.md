# Secure Boot per Linux Embedded

## Introduzione

Questa guida nasce dallo studio del talk "Secure Boot for Embedded Linux: Explained in Simple Words"
di Roy Jamil (Ac6).

L'obiettivo non è descrivere ogni dettaglio implementativo dei vari vendor, ma capire
i concetti fondamentali che stanno dietro al Secure Boot nei sistemi Linux embedded.

La domanda centrale è semplice:

> Come faccio a garantire che il dispositivo esegua soltanto il software che ho approvato?

---

## Il problema da risolvere

Immagina una telecamera IP, un router, un gateway industriale oppure un frigorifero
intelligente.

Tutti questi dispositivi eseguono software:

- bootloader
- kernel Linux
- device tree
- root filesystem
- applicazioni

Se un attaccante riesce a modificare uno di questi componenti, il dispositivo potrebbe
continuare ad avviarsi normalmente eseguendo però codice malevolo.

Secure Boot nasce per impedire questo scenario.

---

## La catena di boot

Una tipica sequenza di avvio Linux embedded è:

```text
Boot ROM
↓
Bootloader (spesso U-Boot)
↓
Kernel Linux
↓
Device Tree
↓
Root Filesystem
↓
Applicazioni
```

In un sistema tradizionale ogni componente carica il successivo.

In un sistema con Secure Boot ogni componente verifica il successivo prima di eseguirlo.

---

## Cos'è realmente Secure Boot

Secure Boot significa:

> Esegui solo software approvato.

Non significa:

- software sicuro
- software privo di bug
- software inattaccabile

Significa soltanto che il codice in esecuzione corrisponde a quello autorizzato.

Questa distinzione è fondamentale.

---

## Secure Boot NON è cifratura

Molto spesso si confondono due concetti:

### Cifratura

Risponde alla domanda:

> Posso leggere questi dati senza la chiave?

Protegge la riservatezza.

### Secure Boot

Risponde alla domanda:

> Questo software è autentico?

Protegge autenticità e integrità.

Le due tecnologie possono convivere ma non sono la stessa cosa.

---

## Hash

Un hash è l'impronta digitale di un file.

Proprietà principali:

- stesso input → stesso hash
- modifica minima → hash completamente diverso
- funzione unidirezionale
- lunghezza fissa

Esempio:

```text
kernel.img
↓
SHA-256
↓
A1B2C3...
```

Se cambia un singolo bit del kernel, cambia completamente l'hash.

---

## Chiave pubblica e chiave privata

Il Secure Boot utilizza normalmente crittografia asimmetrica.

Esistono due chiavi:

```text
Chiave privata
↓
Firma

Chiave pubblica
↓
Verifica
```

La chiave privata deve rimanere segreta.

La chiave pubblica può essere distribuita.

Se la chiave privata viene compromessa, l'intero sistema di fiducia viene compromesso.

---

## Firma digitale

Procedura semplificata:

1. Calcolo hash del file.
2. Firma dell'hash con la chiave privata.
3. Allego la firma all'immagine.

Verifica:

1. Ricalcolo l'hash.
2. Verifico la firma usando la chiave pubblica.
3. Confronto i risultati.

Se coincidono, il file è autentico.

---

## Root of Trust

Ogni catena di fiducia deve partire da un punto fidato.

Questo punto si chiama Root of Trust.

Nei sistemi embedded è generalmente composto da:

- Boot ROM
- OTP Fuses
- Secure Enclave o hardware equivalente

La Root of Trust rappresenta il primo elemento considerato affidabile.

---

## OTP Fuses

OTP significa:

```text
One Time Programmable
```

Sono bit programmabili una sola volta.

Normalmente vengono usati per conservare:

- hash delle chiavi pubbliche
- configurazioni di sicurezza
- informazioni di revoca

Una volta programmati non possono essere modificati.

---

## Perché si memorizza l'hash della chiave pubblica

Le chiavi pubbliche possono essere grandi.

Le OTP fuse sono molto limitate.

Per questo motivo si memorizza:

```text
hash(chiave pubblica)
```

Durante il boot:

1. Il dispositivo legge la chiave pubblica.
2. Calcola il suo hash.
3. Lo confronta con quello nelle fuse.
4. Se coincidono, la chiave è considerata valida.

---

## Chain of Trust

La Chain of Trust è il cuore del Secure Boot.

Ogni componente verifica il successivo.

```text
ROM
↓ verifica
First Stage Bootloader
↓ verifica
Trusted Firmware
↓ verifica
U-Boot
↓ verifica
Kernel
↓ verifica
RootFS
```

Se un anello fallisce, il boot viene interrotto.

---

## FIT Images e U-Boot

Nel mondo U-Boot è molto comune utilizzare le FIT Images.

Una FIT Image può contenere:

- kernel
- device tree
- initramfs
- firme
- configurazioni

Vantaggio:

Un unico contenitore verificabile.

---

## Perché firmare anche il Device Tree

Errore classico:

```text
Kernel firmato
DTB non firmato
```

Il Device Tree descrive l'hardware.

Modificandolo è possibile alterare il comportamento del sistema.

Per questo motivo va verificato insieme al kernel.

---

## DM-Verity

Il kernel è un file singolo.

Il root filesystem contiene migliaia di file.

Serve quindi un approccio diverso.

DM-Verity consente di verificare l'integrità del filesystem tramite alberi hash.

È molto comune nei sistemi embedded read-only.

Spesso viene utilizzato con:

- SquashFS
- immagini immutabili

---

## Secure Boot e TrustZone

Sono concetti differenti.

### Secure Boot

Controlla cosa può partire.

### TrustZone

Controlla cosa può accedere a risorse sensibili durante l'esecuzione.

---

## Arm Trusted Firmware

Molte piattaforme ARM utilizzano:

### BL1

Boot iniziale.

### BL2

Setup iniziale e periferiche sicure.

### BL31

Secure Monitor.

### BL32

Secure OS (spesso OP-TEE).

### BL33

Bootloader del mondo normale (spesso U-Boot).

---

## OP-TEE

OP-TEE è un sistema operativo sicuro open source.

Non è un Linux parallelo.

Serve principalmente per:

- applicazioni fidate
- gestione chiavi
- servizi crittografici
- memoria sicura
- periferiche sicure

Linux comunica con OP-TEE tramite driver dedicati.

---

## Secure World e Normal World

TrustZone divide il sistema in due mondi.

### Normal World

- Linux
- Applicazioni utente

### Secure World

- OP-TEE
- Trusted Applications
- Secure Services

L'obiettivo è isolare le informazioni sensibili.

---

## Esempio STM32MP

Schema semplificato:

```text
Boot ROM
↓
TF-A
↓
U-Boot
↓
Linux
```

Ogni fase verifica la successiva.

---

## Esempio NXP i.MX

NXP utilizza AHAB:

```text
Advanced High Assurance Boot
```

Le immagini firmate vengono inserite in contenitori specifici.

Molti SoC includono anche:

```text
EdgeLock Secure Enclave
```

che custodisce chiavi e operazioni crittografiche.

---

## Cosa garantisce Secure Boot

Garantisce che:

- il bootloader è quello autorizzato
- il kernel è quello autorizzato
- il sistema parte da uno stato noto
- immagini modificate vengono rifiutate

---

## Cosa NON garantisce

Non garantisce:

- assenza di bug
- assenza di vulnerabilità
- sicurezza delle applicazioni
- sicurezza dopo il boot
- protezione delle chiavi private

Secure Boot non è magia.

È soltanto il primo mattone della sicurezza.

---

## Errori comuni

Tra gli errori più frequenti:

- firmare il kernel ma non il DTB
- dimenticare la Root of Trust
- lasciare aperta la console U-Boot
- conservare male le chiavi private
- verificare solo il percorso felice
- non testare immagini corrotte

---

## Mentalità corretta di test

Test valido:

```text
Immagine valida
→ boot riuscito
```

Test ancora più importante:

```text
Immagine alterata
→ boot fallito
```

Se un'immagine modificata continua ad avviarsi, Secure Boot non sta facendo il suo lavoro.

---

## Collegamento con Yocto

Yocto non implementa automaticamente Secure Boot.

Yocto costruisce:

- bootloader
- kernel
- root filesystem
- immagini

Successivamente questi componenti possono essere:

- firmati
- verificati
- integrati nella Chain of Trust

Per questo motivo è importante capire prima Yocto e poi Secure Boot.

---

## Percorso di studio consigliato

1. Costruire una immagine Yocto minima.
2. Avviarla in QEMU.
3. Comprendere U-Boot.
4. Studiare le FIT Images.
5. Studiare le firme digitali.
6. Studiare DM-Verity.
7. Studiare OP-TEE.
8. Studiare Secure Boot completo su hardware reale.

---

## Glossario rapido

**Hash**
Impronta digitale di un file.

**Firma digitale**
Prova che un file è stato firmato da una chiave privata.

**Root of Trust**
Primo elemento considerato affidabile.

**Chain of Trust**
Sequenza di verifiche lungo il boot.

**FIT Image**
Contenitore U-Boot che può includere kernel, DTB e firme.

**OTP Fuse**
Memoria programmabile una sola volta.

**DM-Verity**
Meccanismo di verifica dell'integrità del filesystem.

**OP-TEE**
Sistema operativo sicuro per TrustZone.

**TrustZone**
Tecnologia ARM che separa mondo normale e mondo sicuro.

---

## Idea chiave da ricordare

La frase più importante dell'intero argomento è probabilmente questa:

> Secure Boot non dimostra che il software sia corretto.
>
> Dimostra che stai eseguendo il software che hai deciso di eseguire.
