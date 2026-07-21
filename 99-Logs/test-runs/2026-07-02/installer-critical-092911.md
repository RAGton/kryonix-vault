# Kryonix Test Run

- Profile: installer-critical
- Date: 2026-07-02T09:29:11-04:00
- Host: inspiron

## installer node test
```txt

> kryxd-ui@0.1.0 test
> node --test "src/tests/**/*.test.js" "src/tests/*.test.js"

TAP version 13
# Subtest: Disco 0 B: bloqueia avanço, não habilita nova partição e mostra erro fatal
ok 1 - Disco 0 B: bloqueia avanço, não habilita nova partição e mostra erro fatal
  ---
  duration_ms: 2.611321
  type: 'test'
  ...
# Subtest: Alocação menor que o disco: botão Nova Partição habilitado, calcula espaço livre
ok 2 - Alocação menor que o disco: botão Nova Partição habilitado, calcula espaço livre
  ---
  duration_ms: 0.71406
  type: 'test'
  ...
# Subtest: Disco totalmente alocado: desabilita botão e emite warning
ok 3 - Disco totalmente alocado: desabilita botão e emite warning
  ---
  duration_ms: 0.460439
  type: 'test'
  ...
# Subtest: Alocação excede o disco: mostra erro de excesso e bloqueia avanço
ok 4 - Alocação excede o disco: mostra erro de excesso e bloqueia avanço
  ---
  duration_ms: 0.594136
  type: 'test'
  ...
# Subtest: Swap não usa mountpoint: validação passa com string vazia
ok 5 - Swap não usa mountpoint: validação passa com string vazia
  ---
  duration_ms: 0.579788
  type: 'test'
  ...
# Subtest: EFI válida: FAT32 e mountpoint correto em UEFI não dá erro
ok 6 - EFI válida: FAT32 e mountpoint correto em UEFI não dá erro
  ---
  duration_ms: 0.354166
  type: 'test'
  ...
# Subtest: EFI inválida: ext4 ou btrfs dá erro de FAT32
ok 7 - EFI inválida: ext4 ou btrfs dá erro de FAT32
  ---
  duration_ms: 0.487621
  type: 'test'
  ...
# Subtest: Root ausente: bloqueia avanço
ok 8 - Root ausente: bloqueia avanço
  ---
  duration_ms: 0.335302
  type: 'test'
  ...
# Subtest: Labels duplicados: warning, não erro fatal
ok 9 - Labels duplicados: warning, não erro fatal
  ---
  duration_ms: 0.950346
  type: 'test'
  ...
# Subtest: i18n Hardcoded Strings Sweep
ok 10 - i18n Hardcoded Strings Sweep
  ---
  duration_ms: 24.788088
  type: 'test'
  ...
# Subtest: estado inicial do fluxo de instalacao e idle
ok 11 - estado inicial do fluxo de instalacao e idle
  ---
  duration_ms: 2.102625
  type: 'test'
  ...
# Subtest: reidratacao a partir do backend preserva logs e fase atual
ok 12 - reidratacao a partir do backend preserva logs e fase atual
  ---
  duration_ms: 0.468647
  type: 'test'
  ...
# Subtest: appendInstallLog concatena chunks sem perder o banner novo
ok 13 - appendInstallLog concatena chunks sem perder o banner novo
  ---
  duration_ms: 0.30833
  type: 'test'
  ...
# Subtest: transicao de status running para completed funciona no modelo
ok 14 - transicao de status running para completed funciona no modelo
  ---
  duration_ms: 0.447667
  type: 'test'
  ...
# Subtest: lista de fases marca falha na fase corrente e expande label
ok 15 - lista de fases marca falha na fase corrente e expande label
  ---
  duration_ms: 0.753232
  type: 'test'
  ...
# Subtest: etapa de rede bloqueia avanço sem conexao ou modo offline
ok 16 - etapa de rede bloqueia avanço sem conexao ou modo offline
  ---
  duration_ms: 5.810839
  type: 'test'
  ...
# Subtest: draft gera install-plan canonico sem vazar estado transitorio
ok 17 - draft gera install-plan canonico sem vazar estado transitorio
  ---
  duration_ms: 1.879869
  type: 'test'
  ...
# Subtest: timezone da etapa final precisa ser IANA canonico
ok 18 - timezone da etapa final precisa ser IANA canonico
  ---
  duration_ms: 1.196702
  type: 'test'
  ...
# Subtest: draft gera install-secrets canonico
ok 19 - draft gera install-secrets canonico
  ---
  duration_ms: 0.395715
  type: 'test'
  ...
# Subtest: WAN DHCP nao exige credenciais PPPoE
ok 20 - WAN DHCP nao exige credenciais PPPoE
  ---
  duration_ms: 0.576469
  type: 'test'
  ...
# Subtest: WAN pode ficar vazia sem bloquear a etapa de rede
ok 21 - WAN pode ficar vazia sem bloquear a etapa de rede
  ---
  duration_ms: 0.635416
  type: 'test'
  ...
# Subtest: WAN PPPoE exige usuario e senha
ok 22 - WAN PPPoE exige usuario e senha
  ---
  duration_ms: 0.996393
  type: 'test'
  ...
# Subtest: validacao por etapa respeita campos UX sem poluir o payload
ok 23 - validacao por etapa respeita campos UX sem poluir o payload
  ---
  duration_ms: 9.641046
  type: 'test'
  ...
# Subtest: single, split e RAID geram payload coerente com o contrato
ok 24 - single, split e RAID geram payload coerente com o contrato
  ---
  duration_ms: 0.770153
  type: 'test'
  ...
# Subtest: single, split e raid10 invalidos geram erros especificos
ok 25 - single, split e raid10 invalidos geram erros especificos
  ---
  duration_ms: 0.854185
  type: 'test'
  ...
# Subtest: storage blocking issues vindos da UI bloqueiam summary e install
ok 26 - storage blocking issues vindos da UI bloqueiam summary e install
  ---
  duration_ms: 0.788834
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload usa 0.0.0.0 como sentinela gateway no modo DHCP (schema exige IPv4)
ok 27 - buildInstallPlanPayload usa 0.0.0.0 como sentinela gateway no modo DHCP (schema exige IPv4)
  ---
  duration_ms: 0.212535
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload inclui gateway quando preenchido no modo static
ok 28 - buildInstallPlanPayload inclui gateway quando preenchido no modo static
  ---
  duration_ms: 0.165249
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload mantém wan objeto vazio quando não há WAN configurada (schema exige wan)
ok 29 - buildInstallPlanPayload mantém wan objeto vazio quando não há WAN configurada (schema exige wan)
  ---
  duration_ms: 0.178145
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload inclui wan quando interface preenchida
ok 30 - buildInstallPlanPayload inclui wan quando interface preenchida
  ---
  duration_ms: 0.160024
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload não vaza campos extras em source
ok 31 - buildInstallPlanPayload não vaza campos extras em source
  ---
  duration_ms: 0.179886
  type: 'test'
  ...
# Subtest: schema validation passa para payload DHCP com gateway omitido
ok 32 - schema validation passa para payload DHCP com gateway omitido
  ---
  duration_ms: 0.347717
  type: 'test'
  ...
# Subtest: schema validation passa para payload static com gateway
ok 33 - schema validation passa para payload static com gateway
  ---
  duration_ms: 0.282293
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload inclui mgmtMode no payload de rede
ok 34 - buildInstallPlanPayload inclui mgmtMode no payload de rede
  ---
  duration_ms: 0.197099
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload modo DHCP mantém mode=dhcp
ok 35 - buildInstallPlanPayload modo DHCP mantém mode=dhcp
  ---
  duration_ms: 0.16032
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload não exporta 0.0.0.0 como gateway real para static
ok 36 - buildInstallPlanPayload não exporta 0.0.0.0 como gateway real para static
  ---
  duration_ms: 0.146644
  type: 'test'
  ...
# Subtest: validacao serverIp aceita 0.0.0.0 no formato (schema exige IPv4 valido)
ok 37 - validacao serverIp aceita 0.0.0.0 no formato (schema exige IPv4 valido)
  ---
  duration_ms: 0.275721
  type: 'test'
  ...
# Subtest: validacao serverIp aceita 127.* no formato (schema so valida IPv4)
ok 38 - validacao serverIp aceita 127.* no formato (schema so valida IPv4)
  ---
  duration_ms: 0.203485
  type: 'test'
  ...
# Subtest: validacao serverIp aceita 169.254.* no formato (schema so valida IPv4)
ok 39 - validacao serverIp aceita 169.254.* no formato (schema so valida IPv4)
  ---
  duration_ms: 0.19665
  type: 'test'
  ...
# Subtest: serverIp valido no modo static: IP publico ou privado e aceito pelo regex
ok 40 - serverIp valido no modo static: IP publico ou privado e aceito pelo regex
  ---
  duration_ms: 0.188486
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload usa serverIp como string sem sanitizacao (schema valida em tempo de execucao)
ok 41 - buildInstallPlanPayload usa serverIp como string sem sanitizacao (schema valida em tempo de execucao)
  ---
  duration_ms: 0.134483
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload nao exporta 0.0.0.0 como serverIp real (sentinel so no schema backend)
ok 42 - buildInstallPlanPayload nao exporta 0.0.0.0 como serverIp real (sentinel so no schema backend)
  ---
  duration_ms: 0.137981
  type: 'test'
  ...
# Subtest: WAN expand/collapse nao afeta campos de rede no payload
ok 43 - WAN expand/collapse nao afeta campos de rede no payload
  ---
  duration_ms: 0.178709
  type: 'test'
  ...
# Subtest: contract: buildInstallPlanPayload preserva fields de contract e exclui senhas
ok 44 - contract: buildInstallPlanPayload preserva fields de contract e exclui senhas
  ---
  duration_ms: 0.326438
  type: 'test'
  ...
# Subtest: contract: buildInstallSecretsPayload isola senhas corretamente
ok 45 - contract: buildInstallSecretsPayload isola senhas corretamente
  ---
  duration_ms: 0.150294
  type: 'test'
  ...
# Subtest: bytesToPercent: clampa e protege total zero
ok 46 - bytesToPercent: clampa e protege total zero
  ---
  duration_ms: 2.001623
  type: 'test'
  ...
# Subtest: buildCurrentBlocks: SSD com Windows mostra existentes + espaço livre, somando ~100%
ok 47 - buildCurrentBlocks: SSD com Windows mostra existentes + espaço livre, somando ~100%
  ---
  duration_ms: 1.148786
  type: 'test'
  ...
# Subtest: buildCurrentBlocks: HDD vazio é 100% espaço livre
ok 48 - buildCurrentBlocks: HDD vazio é 100% espaço livre
  ---
  duration_ms: 0.298985
  type: 'test'
  ...
# Subtest: kryonix-default: boot 512M + root restante, válido em disco grande
ok 49 - kryonix-default: boot 512M + root restante, válido em disco grande
  ---
  duration_ms: 1.110592
  type: 'test'
  ...
# Subtest: prevenção de erro: root < 20GB é bloqueado
ok 50 - prevenção de erro: root < 20GB é bloqueado
  ---
  duration_ms: 0.492215
  type: 'test'
  ...
# Subtest: prevenção de erro: layout sem boot é bloqueado
ok 51 - prevenção de erro: layout sem boot é bloqueado
  ---
  duration_ms: 0.415314
  type: 'test'
  ...
# Subtest: toDiskoPartitions: shape do schema (size string, format bool)
ok 52 - toDiskoPartitions: shape do schema (size string, format bool)
  ---
  duration_ms: 0.634314
  type: 'test'
  ...
# Subtest: dual-boot: SSD sem espaço livre suficiente sinaliza resize ou erro (nunca finge sucesso)
ok 53 - dual-boot: SSD sem espaço livre suficiente sinaliza resize ou erro (nunca finge sucesso)
  ---
  duration_ms: 0.412737
  type: 'test'
  ...
# Subtest: dual-boot: disco cheio (sem espaço livre) recusa sem prometer resize
ok 54 - dual-boot: disco cheio (sem espaço livre) recusa sem prometer resize
  ---
  duration_ms: 0.987045
  type: 'test'
  ...
# Subtest: manual: marca layout manual e é inválido até definição
ok 55 - manual: marca layout manual e é inválido até definição
  ---
  duration_ms: 0.983161
  type: 'test'
  ...
# Subtest: validateDiskAllocation: lida com disco 0 bytes
ok 56 - validateDiskAllocation: lida com disco 0 bytes
  ---
  duration_ms: 0.567893
  type: 'test'
  ...
# Subtest: validateDiskAllocation: calcula corretamente alocação normal e total
ok 57 - validateDiskAllocation: calcula corretamente alocação normal e total
  ---
  duration_ms: 0.545074
  type: 'test'
  ...
# Subtest: validateDiskAllocation: erro em over-allocation
ok 58 - validateDiskAllocation: erro em over-allocation
  ---
  duration_ms: 0.402051
  type: 'test'
  ...
# Subtest: merge de countries preserva catálogo interno e deduplica aliases previsíveis
ok 59 - merge de countries preserva catálogo interno e deduplica aliases previsíveis
  ---
  duration_ms: 3.579323
  type: 'test'
  ...
# Subtest: merge de keymaps deduplica case e separadores preservando fallback amigável
ok 60 - merge de keymaps deduplica case e separadores preservando fallback amigável
  ---
  duration_ms: 0.752032
  type: 'test'
  ...
# Subtest: merge de locales colapsa utf8 e underscore/hífen preservando forma canônica interna
ok 61 - merge de locales colapsa utf8 e underscore/hífen preservando forma canônica interna
  ---
  duration_ms: 1.570472
  type: 'test'
  ...
# Subtest: fetchCanonicalCatalog entra em degraded mode quando a API precisa ser complementada
ok 62 - fetchCanonicalCatalog entra em degraded mode quando a API precisa ser complementada
  ---
  duration_ms: 0.68272
  type: 'test'
  ...
# Subtest: fetchCanonicalCatalog usa só o fallback quando a API falha
ok 63 - fetchCanonicalCatalog usa só o fallback quando a API falha
  ---
  duration_ms: 0.755795
  type: 'test'
  ...
# Subtest: layoutAssistant - parseSizeInput: parses raw numbers correctly
ok 64 - layoutAssistant - parseSizeInput: parses raw numbers correctly
  ---
  duration_ms: 4.547319
  type: 'test'
  ...
# Subtest: layoutAssistant - parseSizeInput: parses GiB, MiB correctly
ok 65 - layoutAssistant - parseSizeInput: parses GiB, MiB correctly
  ---
  duration_ms: 1.420037
  type: 'test'
  ...
# Subtest: layoutAssistant - parseSizeInput: parses percentages based on total
ok 66 - layoutAssistant - parseSizeInput: parses percentages based on total
  ---
  duration_ms: 0.312609
  type: 'test'
  ...
# Subtest: layoutAssistant - parseSizeInput: parses resto / restante based on free bytes
ok 67 - layoutAssistant - parseSizeInput: parses resto / restante based on free bytes
  ---
  duration_ms: 2.131215
  type: 'test'
  ...
# Subtest: layoutAssistant - parseSizeInput: handles invalid inputs safely
ok 68 - layoutAssistant - parseSizeInput: handles invalid inputs safely
  ---
  duration_ms: 0.36567
  type: 'test'
  ...
# Subtest: layoutAssistant - validateProposedLayout: fails if no root partition is defined
ok 69 - layoutAssistant - validateProposedLayout: fails if no root partition is defined
  ---
  duration_ms: 0.658161
  type: 'test'
  ...
# Subtest: layoutAssistant - validateProposedLayout: fails if root partition is too small
ok 70 - layoutAssistant - validateProposedLayout: fails if root partition is too small
  ---
  duration_ms: 0.488286
  type: 'test'
  ...
# Subtest: layoutAssistant - validateProposedLayout: passes for valid layouts
ok 71 - layoutAssistant - validateProposedLayout: passes for valid layouts
  ---
  duration_ms: 0.392999
  type: 'test'
  ...
# Subtest: raid options respect minimum member count and parity rules
ok 72 - raid options respect minimum member count and parity rules
  ---
  duration_ms: 7.245884
  type: 'test'
  ...
# Subtest: conservative validation blocks heterogeneous raid1/5/10 but still allows raid0
ok 73 - conservative validation blocks heterogeneous raid1/5/10 but still allows raid0
  ---
  duration_ms: 1.241642
  type: 'test'
  ...
# Subtest: raid summary calculates usable capacity conservatively
ok 74 - raid summary calculates usable capacity conservatively
  ---
  duration_ms: 1.059358
  type: 'test'
  ...
# Subtest: single profile rejects more than two selected disks
ok 75 - single profile rejects more than two selected disks
  ---
  duration_ms: 0.607055
  type: 'test'
  ...
# Subtest: single disk layout accepts one root disk and split requires roles distintos
ok 76 - single disk layout accepts one root disk and split requires roles distintos
  ---
  duration_ms: 25.195646
  type: 'test'
  ...
# Subtest: split summary reports explicit system and data disks
ok 77 - split summary reports explicit system and data disks
  ---
  duration_ms: 0.792095
  type: 'test'
  ...
# Subtest: storage recommendation prefers safe redundant profiles
ok 78 - storage recommendation prefers safe redundant profiles
  ---
  duration_ms: 2.319277
  type: 'test'
  ...
# Subtest: installExecution
    # Subtest: createInitialExecutionState
        # Subtest: creates idle state
        ok 1 - creates idle state
          ---
          duration_ms: 1.589997
          type: 'test'
          ...
        1..1
    ok 1 - createInitialExecutionState
      ---
      duration_ms: 4.952603
      type: 'suite'
      ...
    # Subtest: hydrateExecutionState
        # Subtest: hydrates running state correctly
        ok 1 - hydrates running state correctly
          ---
          duration_ms: 0.721997
          type: 'test'
          ...
        # Subtest: hydrates completed state
        ok 2 - hydrates completed state
          ---
          duration_ms: 0.329448
          type: 'test'
          ...
        # Subtest: hydrates failed state
        ok 3 - hydrates failed state
          ---
          duration_ms: 0.326049
          type: 'test'
          ...
        1..3
    ok 2 - hydrateExecutionState
      ---
      duration_ms: 2.05328
      type: 'suite'
      ...
    # Subtest: applyExecutionStatus
        # Subtest: transitions state correctly
        ok 1 - transitions state correctly
          ---
          duration_ms: 0.783365
          type: 'test'
          ...
        1..1
    ok 3 - applyExecutionStatus
      ---
      duration_ms: 1.039505
      type: 'suite'
      ...
    # Subtest: buildInstallStageList
        # Subtest: marks completed phases as done and current as active
        ok 1 - marks completed phases as done and current as active
          ---
          duration_ms: 1.065194
          type: 'test'
          ...
        # Subtest: marks all as done if completed
        ok 2 - marks all as done if completed
          ---
          duration_ms: 0.386702
          type: 'test'
          ...
        # Subtest: marks current phase as failed if failed
        ok 3 - marks current phase as failed if failed
          ---
          duration_ms: 0.338537
          type: 'test'
          ...
        1..3
    ok 4 - buildInstallStageList
      ---
      duration_ms: 2.501612
      type: 'suite'
      ...
    1..4
ok 79 - installExecution
  ---
  duration_ms: 12.111838
  type: 'suite'
  ...
# Subtest: installPlan
    # Subtest: isStrongPassword
        # Subtest: requires at least 12 characters
        ok 1 - requires at least 12 characters
          ---
          duration_ms: 1.727247
          type: 'test'
          ...
        # Subtest: requires at least 3 character classes
        ok 2 - requires at least 3 character classes
          ---
          duration_ms: 0.627501
          type: 'test'
          ...
        1..2
    ok 1 - isStrongPassword
      ---
      duration_ms: 3.914248
      type: 'suite'
      ...
    # Subtest: buildInstallPlanPayload
        # Subtest: builds a default valid payload
        ok 1 - builds a default valid payload
          ---
          duration_ms: 2.545568
          type: 'test'
          ...
        # Subtest: activates srvData appropriately
        ok 2 - activates srvData appropriately
          ---
          duration_ms: 0.6586
          type: 'test'
          ...
        1..2
    ok 2 - buildInstallPlanPayload
      ---
      duration_ms: 3.607314
      type: 'suite'
      ...
    # Subtest: validateStep
        # Subtest: validates eula step
        ok 1 - validates eula step
          ---
          duration_ms: 2.395838
          type: 'test'
          ...
        # Subtest: validates network step
        ok 2 - validates network step
          ---
          duration_ms: 1.194684
          type: 'test'
          ...
        # Subtest: validates users step with weak password
        ok 3 - validates users step with weak password
          ---
          duration_ms: 1.229697
          type: 'test'
          ...
        # Subtest: allows weak password if allowWeakPassword is true
        ok 4 - allows weak password if allowWeakPassword is true
          ---
          duration_ms: 1.035817
          type: 'test'
          ...
        1..4
    ok 3 - validateStep
      ---
      duration_ms: 6.726379
      type: 'suite'
      ...
    1..3
ok 80 - installPlan
  ---
  duration_ms: 15.639256
  type: 'suite'
  ...
# Subtest: storagePlanner
    # Subtest: validateSingleDiskLayout
        # Subtest: requires a selected disk
        ok 1 - requires a selected disk
          ---
          duration_ms: 1.68834
          type: 'test'
          ...
        # Subtest: validates eligible disk
        ok 2 - validates eligible disk
          ---
          duration_ms: 0.67033
          type: 'test'
          ...
        # Subtest: rejects ineligible disk
        ok 3 - rejects ineligible disk
          ---
          duration_ms: 0.531697
          type: 'test'
          ...
        1..3
    ok 1 - validateSingleDiskLayout
      ---
      duration_ms: 4.148794
      type: 'suite'
      ...
    # Subtest: validateSplitDiskLayout
        # Subtest: requires both disks to be different
        ok 1 - requires both disks to be different
          ---
          duration_ms: 0.582085
          type: 'test'
          ...
        # Subtest: validates two distinct eligible disks
        ok 2 - validates two distinct eligible disks
          ---
          duration_ms: 0.504003
          type: 'test'
          ...
        1..2
    ok 2 - validateSplitDiskLayout
      ---
      duration_ms: 1.394611
      type: 'suite'
      ...
    # Subtest: validateRaidSelection
        # Subtest: validates RAID 1 with 2 homogeneous disks
        ok 1 - validates RAID 1 with 2 homogeneous disks
          ---
          duration_ms: 1.209923
          type: 'test'
          ...
        # Subtest: rejects RAID 1 with heterogeneous disks if deviation > 5%
        ok 2 - rejects RAID 1 with heterogeneous disks if deviation > 5%
          ---
          duration_ms: 0.708135
          type: 'test'
          ...
        # Subtest: validates RAID 0 with heterogeneous disks but warns about waste
        ok 3 - validates RAID 0 with heterogeneous disks but warns about waste
          ---
          duration_ms: 1.586756
          type: 'test'
          ...
        # Subtest: rejects RAID 5 with < 3 disks
        ok 4 - rejects RAID 5 with < 3 disks
          ---
          duration_ms: 0.411291
          type: 'test'
          ...
        # Subtest: rejects RAID 10 with odd number of disks (5 disks)
        ok 5 - rejects RAID 10 with odd number of disks (5 disks)
          ---
          duration_ms: 0.842255
          type: 'test'
          ...
        1..5
    ok 3 - validateRaidSelection
      ---
      duration_ms: 5.44902
      type: 'suite'
      ...
    1..3
ok 81 - storagePlanner
  ---
  duration_ms: 12.305054
  type: 'suite'
  ...
# Subtest: fuzz: splitWizardPatch nunca vaza chaves desconhecidas nem polui o prototype
ok 82 - fuzz: splitWizardPatch nunca vaza chaves desconhecidas nem polui o prototype
  ---
  duration_ms: 30.498756
  type: 'test'
  ...
# Subtest: fuzz: input hostil de localStorage (JSON com __proto__) não polui Object.prototype
ok 83 - fuzz: input hostil de localStorage (JSON com __proto__) não polui Object.prototype
  ---
  duration_ms: 0.44411
  type: 'test'
  ...
# Subtest: fuzz: validateStep(network) trata httpPort exatamente como o payload define
ok 84 - fuzz: validateStep(network) trata httpPort exatamente como o payload define
  ---
  duration_ms: 103.902562
  type: 'test'
  ...
# Subtest: fuzz: validateStep(network) modo estático rejeita IP/gateway malformados
ok 85 - fuzz: validateStep(network) modo estático rejeita IP/gateway malformados
  ---
  duration_ms: 115.478148
  type: 'test'
  ...
# Subtest: fuzz: validateStep nunca lança para drafts arbitrários em qualquer step
ok 86 - fuzz: validateStep nunca lança para drafts arbitrários em qualquer step
  ---
  duration_ms: 237.332712
  type: 'test'
  ...
# Subtest: fuzz: mergeWizardState é estável sob re-split repetido
ok 87 - fuzz: mergeWizardState é estável sob re-split repetido
  ---
  duration_ms: 76.864453
  type: 'test'
  ...
# Subtest: draft e uiState nao vazam campos um para o outro
ok 88 - draft e uiState nao vazam campos um para o outro
  ---
  duration_ms: 3.292304
  type: 'test'
  ...
# Subtest: mergeWizardState preserva selectedDisks do draft
ok 89 - mergeWizardState preserva selectedDisks do draft
  ---
  duration_ms: 0.695514
  type: 'test'
  ...
1..89
# tests 112
# suites 13
# pass 112
# fail 0
# cancelled 0
# skipped 0
# todo 0
# duration_ms 1121.819278
```
- installer node test: PASS


Final status: PASS
