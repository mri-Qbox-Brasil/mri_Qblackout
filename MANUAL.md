# mri_Qblackout — Manual

Caixa de fusíveis interativa que derruba a energia da cidade por um tempo determinado, com cooldown.

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Configuração](#configuração)
4. [Funcionamento](#funcionamento)
5. [Entrypoints para outros recursos](#entrypoints-para-outros-recursos)
6. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `qb-core` | Sim | Framework base e notificações |
| `qb-target` | Sim | Declarado em `dependencies` do `fxmanifest.lua`. Cria a box zone da caixa de fusíveis |
| `PolyZone` | Sim | Carregado via `@PolyZone/client.lua` e `@PolyZone/BoxZone.lua` nos `shared_scripts` |
| `qb-weathersync` | Sim | O servidor chama `exports["qb-weathersync"]:setBlackout()`. Sem ele o blackout não acontece |

---

## Instalação

1. Copie a pasta `mri_Qblackout` para `resources/`.
2. Adicione ao `server.cfg`:
   ```
   ensure mri_Qblackout
   ```
3. Não há SQL nem itens de inventário a cadastrar.

---

## Configuração

Arquivo: `config.lua`.

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `Config.BlackoutTime` | number (ms) | Sim | Quanto tempo as luzes ficam apagadas antes de voltarem. Padrão: `20000` |
| `Config.Cooldown` | number (ms) | Sim | Cooldown contado depois que as luzes voltam, durante o qual não é possível derrubar a energia de novo. Padrão: `20000` |
| `Config.AlreadyActiveMessage` | string | Sim | Notificação exibida quando alguém tenta acionar a caixa com o blackout já ativo |
| `Config.RecentlyHitMessage` | string | Sim | Notificação exibida quando alguém tenta acionar a caixa durante o cooldown |

As coordenadas da caixa de fusíveis não são configuráveis: estão fixas no código, em `vector3(713.01, 161.07, 81.10)` (box zone do `qb-target`, em `client/main.lua`), com o prop `reh_prop_reh_b_computer_04a` criado pelo servidor em `713.9, 160.55, 79.75`.

---

## Funcionamento

1. O jogador mira a caixa de fusíveis com o `qb-target` e escolhe a opção "Desligue a energia da Cidade".
2. O servidor valida o estado: se já houver blackout ativo ou se o cooldown ainda estiver correndo, apenas envia a notificação correspondente.
3. Caso contrário, o prop da caixa é movido para fora de vista e o cliente executa uma cena sincronizada (`anim@scripted@ulp_missions@fuse@male@`) de abertura e sabotagem do painel.
4. Passados 17 segundos, o prop volta ao lugar e o blackout é ligado via `qb-weathersync`.
5. Após `Config.BlackoutTime`, as luzes voltam e começa o cooldown de `Config.Cooldown`.

---

## Entrypoints para outros recursos

Todos os eventos usam o prefixo legado `ss-blackout` (o recurso é um fork do "Blackout Script" de Sam Scripts).

### Eventos de servidor

```lua
-- Aciona a tentativa de blackout para o jogador que disparou (é o que o qb-target chama)
TriggerServerEvent('ss-blackout:blackout')

-- Liga/desliga o blackout diretamente via qb-weathersync, sem checagens nem animação
TriggerEvent('ss-blackout:blackouton')
TriggerEvent('ss-blackout:blackoutoff')
```

### Eventos de cliente

```lua
-- Executa a cena sincronizada de sabotagem da caixa de fusíveis
TriggerClientEvent('ss-blackout:enterbox', source)

-- Notificações de erro
TriggerClientEvent('ss-blackout:recentlyhitnotification', source)
TriggerClientEvent('ss-blackout:blackoutactivenotification', source)
```

---

## Estrutura de arquivos

```
mri_Qblackout/
├── client/
│   └── main.lua      — cena sincronizada da caixa, notificações e box zone do qb-target
├── server/
│   └── main.lua      — estado do blackout, cooldown, prop da caixa e chamada ao qb-weathersync
├── config.lua        — tempos de blackout/cooldown e textos das notificações
└── fxmanifest.lua
```
