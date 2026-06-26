# The Glitchrooms — Game Design Document

## Tema da Jam

**Glitch!**

## High Concept

The Glitchrooms é um runner rítmico em que um personagem de um jogo normal clipa para fora da fase e cai em uma dimensão corrompida. Preso entre salas impossíveis e corredores quebrados, ele precisa fugir de uma entidade-glitch que tenta deletá-lo do jogo.

## Inspirações

* Geometry Dash: ritmo, corrida automática, obstáculos sincronizados.
* The Backrooms: sensação de lugar impossível, liminal e opressivo.
* Murder Drones: estética tecnológica, glitch, ameaça agressiva e visual caótico.

## Gênero

Runner rítmico / plataforma 2D.

## Plataforma

PC.

## Engine

Godot.

## Linguagem

GDScript.

## Objetivo do Jogador

Sobreviver até o final da fase enquanto foge da entidade-glitch.

## Core Loop

1. O personagem corre automaticamente.
2. O jogador reage aos obstáculos no ritmo da música.
3. O jogador pula, desvia e usa poderes de glitch.
4. Erros fazem a entidade se aproximar.
5. O jogador vence ao alcançar a porta de saída no fim da fase.

## Mecânicas Principais

* Corrida automática.
* Pulo.
* Obstáculos rítmicos.
* Poder de No-Clip para atravessar obstáculos glitchados.
* Sistema de perseguição visual da entidade.

## Poder Principal: No-Clip

O jogador pode atravessar certos obstáculos corrompidos por um curto período. Esses obstáculos terão visual diferente, como distorção, flicker ou transparência. O poder tem cooldown curto para evitar spam.

## Mecânica de Perigo

A entidade-glitch persegue o jogador. Quando o jogador erra, a entidade se aproxima. Caso ela alcance o jogador, ele é deletado.

## Condição de Vitória

Chegar ao final da fase e atravessar a porta de saída.

## Condição de Derrota

Ser alcançado pela entidade-glitch ou colidir com obstáculos fatais vezes demais.

## Escopo Mínimo

* Uma fase de 60 a 90 segundos.
* Um personagem jogável.
* Uma entidade perseguidora.
* Obstáculos básicos.
* Obstáculos glitcháveis.
* Poder de No-Clip.
* Música com obstáculos posicionados manualmente no ritmo.
* Tela de início e tela de vitória/derrota.

## Estética

Ambiente liminal inspirado em Backrooms, com corredores amarelos, luzes fluorescentes, paredes repetidas e elementos corrompidos. A corrupção visual aumenta conforme a entidade se aproxima.

## Tom

Tenso, estranho e acelerado. O jogo deve parecer que o jogador está dentro de um arquivo quebrado que está tentando expulsá-lo.

## Prioridades

### Must Have

* Movimento automático.
* Pulo.
* Obstáculos.
* Uma fase completa.
* Entidade perseguindo.
* No-Clip.
* Vitória e derrota.

### Should Have

* Música sincronizada com obstáculos.
* Efeitos visuais de glitch.
* Sons de erro, distorção e passos da entidade.
* Pequena introdução visual.

### Could Have

* Lag Spike.
* Checkpoints.
* Cutscene curta.
* Diferentes salas dentro da fase.
