# Kryonix Test Run

- Profile: installer-critical
- Date: 2026-07-01T17:37:10-04:00
- Host: inspiron

## installer node test
```txt

> kryxd-ui@0.1.0 test
> node --test "src/tests/**/*.test.js" "src/tests/*.test.js"

TAP version 13
# Subtest: Disco 0 B: bloqueia avanço, não habilita nova partição e mostra erro fatal
ok 1 - Disco 0 B: bloqueia avanço, não habilita nova partição e mostra erro fatal
  ---
  duration_ms: 2.662501
  type: 'test'
  ...
# Subtest: Alocação menor que o disco: botão Nova Partição habilitado, calcula espaço livre
ok 2 - Alocação menor que o disco: botão Nova Partição habilitado, calcula espaço livre
  ---
  duration_ms: 0.892806
  type: 'test'
  ...
# Subtest: Disco totalmente alocado: desabilita botão e emite warning
ok 3 - Disco totalmente alocado: desabilita botão e emite warning
  ---
  duration_ms: 0.512253
  type: 'test'
  ...
# Subtest: Alocação excede o disco: mostra erro de excesso e bloqueia avanço
ok 4 - Alocação excede o disco: mostra erro de excesso e bloqueia avanço
  ---
  duration_ms: 0.598178
  type: 'test'
  ...
# Subtest: Swap não usa mountpoint: validação passa com string vazia
ok 5 - Swap não usa mountpoint: validação passa com string vazia
  ---
  duration_ms: 0.606654
  type: 'test'
  ...
# Subtest: EFI válida: FAT32 e mountpoint correto em UEFI não dá erro
ok 6 - EFI válida: FAT32 e mountpoint correto em UEFI não dá erro
  ---
  duration_ms: 0.352179
  type: 'test'
  ...
# Subtest: EFI inválida: ext4 ou btrfs dá erro de FAT32
ok 7 - EFI inválida: ext4 ou btrfs dá erro de FAT32
  ---
  duration_ms: 0.765447
  type: 'test'
  ...
# Subtest: Root ausente: bloqueia avanço
ok 8 - Root ausente: bloqueia avanço
  ---
  duration_ms: 0.354168
  type: 'test'
  ...
# Subtest: Labels duplicados: warning, não erro fatal
ok 9 - Labels duplicados: warning, não erro fatal
  ---
  duration_ms: 0.965354
  type: 'test'
  ...
# Found hardcoded strings that need i18n translation:
#   pages/SystemFeatures.jsx: "Partial"
#   pages/UserFeatures.jsx: "Partial"
# Subtest: i18n Hardcoded Strings Sweep
not ok 10 - i18n Hardcoded Strings Sweep
  ---
  duration_ms: 31.394277
  type: 'test'
  location: '/home/rocha/kryonix/kryonix-dev/repos/kryxd/ui/src/tests/i18nHardcodedStrings.test.js:46:1'
  failureType: 'testCodeFailure'
  error: |-
    Found 2 hardcoded strings. Please translate them using i18next t().
    
    2 !== 0
    
  code: 'ERR_ASSERTION'
  name: 'AssertionError'
  expected: 0
  actual: 2
  operator: 'strictEqual'
  stack: |-
    TestContext.<anonymous> (file:///home/rocha/kryonix/kryonix-dev/repos/kryxd/ui/src/tests/i18nHardcodedStrings.test.js:97:10)
    Test.runInAsyncScope (node:async_hooks:214:14)
    Test.run (node:internal/test_runner/test:1047:25)
    Test.start (node:internal/test_runner/test:944:17)
    startSubtestAfterBootstrap (node:internal/test_runner/harness:296:17)
  ...
# Subtest: estado inicial do fluxo de instalacao e idle
ok 11 - estado inicial do fluxo de instalacao e idle
  ---
  duration_ms: 1.370713
  type: 'test'
  ...
# Subtest: reidratacao a partir do backend preserva logs e fase atual
ok 12 - reidratacao a partir do backend preserva logs e fase atual
  ---
  duration_ms: 0.414274
  type: 'test'
  ...
# Subtest: appendInstallLog concatena chunks sem perder o banner novo
ok 13 - appendInstallLog concatena chunks sem perder o banner novo
  ---
  duration_ms: 0.206415
  type: 'test'
  ...
# Subtest: transicao de status running para completed funciona no modelo
ok 14 - transicao de status running para completed funciona no modelo
  ---
  duration_ms: 0.263971
  type: 'test'
  ...
# Subtest: lista de fases marca falha na fase corrente e expande label
ok 15 - lista de fases marca falha na fase corrente e expande label
  ---
  duration_ms: 0.559926
  type: 'test'
  ...
# Subtest: etapa de rede bloqueia avanço sem conexao ou modo offline
ok 16 - etapa de rede bloqueia avanço sem conexao ou modo offline
  ---
  duration_ms: 3.656388
  type: 'test'
  ...
# Subtest: draft gera install-plan canonico sem vazar estado transitorio
ok 17 - draft gera install-plan canonico sem vazar estado transitorio
  ---
  duration_ms: 1.41032
  type: 'test'
  ...
# Subtest: timezone da etapa final precisa ser IANA canonico
ok 18 - timezone da etapa final precisa ser IANA canonico
  ---
  duration_ms: 1.160334
  type: 'test'
  ...
# Subtest: draft gera install-secrets canonico
ok 19 - draft gera install-secrets canonico
  ---
  duration_ms: 0.272762
  type: 'test'
  ...
# Subtest: WAN DHCP nao exige credenciais PPPoE
ok 20 - WAN DHCP nao exige credenciais PPPoE
  ---
  duration_ms: 0.412044
  type: 'test'
  ...
# Subtest: WAN pode ficar vazia sem bloquear a etapa de rede
ok 21 - WAN pode ficar vazia sem bloquear a etapa de rede
  ---
  duration_ms: 0.894802
  type: 'test'
  ...
# Subtest: WAN PPPoE exige usuario e senha
ok 22 - WAN PPPoE exige usuario e senha
  ---
  duration_ms: 2.629202
  type: 'test'
  ...
# Subtest: validacao por etapa respeita campos UX sem poluir o payload
ok 23 - validacao por etapa respeita campos UX sem poluir o payload
  ---
  duration_ms: 6.937889
  type: 'test'
  ...
# Subtest: single, split e RAID geram payload coerente com o contrato
ok 24 - single, split e RAID geram payload coerente com o contrato
  ---
  duration_ms: 0.761246
  type: 'test'
  ...
# Subtest: single, split e raid10 invalidos geram erros especificos
ok 25 - single, split e raid10 invalidos geram erros especificos
  ---
  duration_ms: 0.869174
  type: 'test'
  ...
# Subtest: storage blocking issues vindos da UI bloqueiam summary e install
ok 26 - storage blocking issues vindos da UI bloqueiam summary e install
  ---
  duration_ms: 0.740915
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload usa 0.0.0.0 como sentinela gateway no modo DHCP (schema exige IPv4)
ok 27 - buildInstallPlanPayload usa 0.0.0.0 como sentinela gateway no modo DHCP (schema exige IPv4)
  ---
  duration_ms: 0.204506
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload inclui gateway quando preenchido no modo static
ok 28 - buildInstallPlanPayload inclui gateway quando preenchido no modo static
  ---
  duration_ms: 0.157012
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload mantém wan objeto vazio quando não há WAN configurada (schema exige wan)
ok 29 - buildInstallPlanPayload mantém wan objeto vazio quando não há WAN configurada (schema exige wan)
  ---
  duration_ms: 0.178421
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload inclui wan quando interface preenchida
ok 30 - buildInstallPlanPayload inclui wan quando interface preenchida
  ---
  duration_ms: 0.147376
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload não vaza campos extras em source
ok 31 - buildInstallPlanPayload não vaza campos extras em source
  ---
  duration_ms: 0.166828
  type: 'test'
  ...
# Subtest: schema validation passa para payload DHCP com gateway omitido
ok 32 - schema validation passa para payload DHCP com gateway omitido
  ---
  duration_ms: 0.319806
  type: 'test'
  ...
# Subtest: schema validation passa para payload static com gateway
ok 33 - schema validation passa para payload static com gateway
  ---
  duration_ms: 0.237424
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload inclui mgmtMode no payload de rede
ok 34 - buildInstallPlanPayload inclui mgmtMode no payload de rede
  ---
  duration_ms: 0.157845
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload modo DHCP mantém mode=dhcp
ok 35 - buildInstallPlanPayload modo DHCP mantém mode=dhcp
  ---
  duration_ms: 0.145136
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload não exporta 0.0.0.0 como gateway real para static
ok 36 - buildInstallPlanPayload não exporta 0.0.0.0 como gateway real para static
  ---
  duration_ms: 0.15409
  type: 'test'
  ...
# Subtest: validacao serverIp aceita 0.0.0.0 no formato (schema exige IPv4 valido)
ok 37 - validacao serverIp aceita 0.0.0.0 no formato (schema exige IPv4 valido)
  ---
  duration_ms: 0.26066
  type: 'test'
  ...
# Subtest: validacao serverIp aceita 127.* no formato (schema so valida IPv4)
ok 38 - validacao serverIp aceita 127.* no formato (schema so valida IPv4)
  ---
  duration_ms: 0.20253
  type: 'test'
  ...
# Subtest: validacao serverIp aceita 169.254.* no formato (schema so valida IPv4)
ok 39 - validacao serverIp aceita 169.254.* no formato (schema so valida IPv4)
  ---
  duration_ms: 0.18668
  type: 'test'
  ...
# Subtest: serverIp valido no modo static: IP publico ou privado e aceito pelo regex
ok 40 - serverIp valido no modo static: IP publico ou privado e aceito pelo regex
  ---
  duration_ms: 0.208827
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload usa serverIp como string sem sanitizacao (schema valida em tempo de execucao)
ok 41 - buildInstallPlanPayload usa serverIp como string sem sanitizacao (schema valida em tempo de execucao)
  ---
  duration_ms: 0.149308
  type: 'test'
  ...
# Subtest: buildInstallPlanPayload nao exporta 0.0.0.0 como serverIp real (sentinel so no schema backend)
ok 42 - buildInstallPlanPayload nao exporta 0.0.0.0 como serverIp real (sentinel so no schema backend)
  ---
  duration_ms: 0.135605
  type: 'test'
  ...
# Subtest: WAN expand/collapse nao afeta campos de rede no payload
ok 43 - WAN expand/collapse nao afeta campos de rede no payload
  ---
  duration_ms: 0.229241
  type: 'test'
  ...
# Subtest: contract: buildInstallPlanPayload preserva fields de contract e exclui senhas
ok 44 - contract: buildInstallPlanPayload preserva fields de contract e exclui senhas
  ---
  duration_ms: 0.413172
  type: 'test'
  ...
# Subtest: contract: buildInstallSecretsPayload isola senhas corretamente
ok 45 - contract: buildInstallSecretsPayload isola senhas corretamente
  ---
  duration_ms: 0.158413
  type: 'test'
  ...
# Subtest: bytesToPercent: clampa e protege total zero
ok 46 - bytesToPercent: clampa e protege total zero
  ---
  duration_ms: 2.04823
  type: 'test'
  ...
# Subtest: buildCurrentBlocks: SSD com Windows mostra existentes + espaço livre, somando ~100%
ok 47 - buildCurrentBlocks: SSD com Windows mostra existentes + espaço livre, somando ~100%
  ---
  duration_ms: 0.970259
  type: 'test'
  ...
# Subtest: buildCurrentBlocks: HDD vazio é 100% espaço livre
ok 48 - buildCurrentBlocks: HDD vazio é 100% espaço livre
  ---
  duration_ms: 0.331418
  type: 'test'
  ...
# Subtest: kryonix-default: boot 512M + root restante, válido em disco grande
ok 49 - kryonix-default: boot 512M + root restante, válido em disco grande
  ---
  duration_ms: 1.063149
  type: 'test'
  ...
# Subtest: prevenção de erro: root < 20GB é bloqueado
ok 50 - prevenção de erro: root < 20GB é bloqueado
  ---
  duration_ms: 0.461371
  type: 'test'
  ...
# Subtest: prevenção de erro: layout sem boot é bloqueado
ok 51 - prevenção de erro: layout sem boot é bloqueado
  ---
  duration_ms: 0.404401
  type: 'test'
  ...
# Subtest: toDiskoPartitions: shape do schema (size string, format bool)
ok 52 - toDiskoPartitions: shape do schema (size string, format bool)
  ---
  duration_ms: 1.019837
  type: 'test'
  ...
# Subtest: dual-boot: SSD sem espaço livre suficiente sinaliza resize ou erro (nunca finge sucesso)
ok 53 - dual-boot: SSD sem espaço livre suficiente sinaliza resize ou erro (nunca finge sucesso)
  ---
  duration_ms: 0.443087
  type: 'test'
  ...
# Subtest: dual-boot: disco cheio (sem espaço livre) recusa sem prometer resize
ok 54 - dual-boot: disco cheio (sem espaço livre) recusa sem prometer resize
  ---
  duration_ms: 0.927423
  type: 'test'
  ...
# Subtest: manual: marca layout manual e é inválido até definição
ok 55 - manual: marca layout manual e é inválido até definição
  ---
  duration_ms: 0.768663
  type: 'test'
  ...
# Subtest: validateDiskAllocation: lida com disco 0 bytes
ok 56 - validateDiskAllocation: lida com disco 0 bytes
  ---
  duration_ms: 0.503908
  type: 'test'
  ...
# Subtest: validateDiskAllocation: calcula corretamente alocação normal e total
ok 57 - validateDiskAllocation: calcula corretamente alocação normal e total
  ---
  duration_ms: 0.448418
  type: 'test'
  ...
# Subtest: validateDiskAllocation: erro em over-allocation
ok 58 - validateDiskAllocation: erro em over-allocation
  ---
  duration_ms: 0.342166
  type: 'test'
  ...
# Subtest: merge de countries preserva catálogo interno e deduplica aliases previsíveis
ok 59 - merge de countries preserva catálogo interno e deduplica aliases previsíveis
  ---
  duration_ms: 3.672477
  type: 'test'
  ...
# Subtest: merge de keymaps deduplica case e separadores preservando fallback amigável
ok 60 - merge de keymaps deduplica case e separadores preservando fallback amigável
  ---
  duration_ms: 0.760722
  type: 'test'
  ...
# Subtest: merge de locales colapsa utf8 e underscore/hífen preservando forma canônica interna
ok 61 - merge de locales colapsa utf8 e underscore/hífen preservando forma canônica interna
  ---
  duration_ms: 2.259996
  type: 'test'
  ...
# Subtest: fetchCanonicalCatalog entra em degraded mode quando a API precisa ser complementada
ok 62 - fetchCanonicalCatalog entra em degraded mode quando a API precisa ser complementada
  ---
  duration_ms: 0.693109
  type: 'test'
  ...
# Subtest: fetchCanonicalCatalog usa só o fallback quando a API falha
ok 63 - fetchCanonicalCatalog usa só o fallback quando a API falha
  ---
  duration_ms: 0.687481
  type: 'test'
  ...
# Subtest: layoutAssistant - parseSizeInput: parses raw numbers correctly
ok 64 - layoutAssistant - parseSizeInput: parses raw numbers correctly
  ---
  duration_ms: 2.74383
  type: 'test'
  ...
# Subtest: layoutAssistant - parseSizeInput: parses GiB, MiB correctly
ok 65 - layoutAssistant - parseSizeInput: parses GiB, MiB correctly
  ---
  duration_ms: 0.466981
  type: 'test'
  ...
# Subtest: layoutAssistant - parseSizeInput: parses percentages based on total
ok 66 - layoutAssistant - parseSizeInput: parses percentages based on total
  ---
  duration_ms: 0.31416
  type: 'test'
  ...
# Subtest: layoutAssistant - parseSizeInput: parses resto / restante based on free bytes
ok 67 - layoutAssistant - parseSizeInput: parses resto / restante based on free bytes
  ---
  duration_ms: 0.332208
  type: 'test'
  ...
# Subtest: layoutAssistant - parseSizeInput: handles invalid inputs safely
ok 68 - layoutAssistant - parseSizeInput: handles invalid inputs safely
  ---
  duration_ms: 0.333022
  type: 'test'
  ...
# Subtest: layoutAssistant - validateProposedLayout: fails if no root partition is defined
ok 69 - layoutAssistant - validateProposedLayout: fails if no root partition is defined
  ---
  duration_ms: 0.661774
  type: 'test'
  ...
# Subtest: layoutAssistant - validateProposedLayout: fails if root partition is too small
ok 70 - layoutAssistant - validateProposedLayout: fails if root partition is too small
  ---
  duration_ms: 0.453259
  type: 'test'
  ...
# Subtest: layoutAssistant - validateProposedLayout: passes for valid layouts
ok 71 - layoutAssistant - validateProposedLayout: passes for valid layouts
  ---
  duration_ms: 0.269193
  type: 'test'
  ...
# Subtest: raid options respect minimum member count and parity rules
ok 72 - raid options respect minimum member count and parity rules
  ---
  duration_ms: 7.526457
  type: 'test'
  ...
# Subtest: conservative validation blocks heterogeneous raid1/5/10 but still allows raid0
ok 73 - conservative validation blocks heterogeneous raid1/5/10 but still allows raid0
  ---
  duration_ms: 1.109596
  type: 'test'
  ...
# Subtest: raid summary calculates usable capacity conservatively
ok 74 - raid summary calculates usable capacity conservatively
  ---
  duration_ms: 1.008829
  type: 'test'
  ...
# Subtest: single profile rejects more than two selected disks
ok 75 - single profile rejects more than two selected disks
  ---
  duration_ms: 0.610713
  type: 'test'
  ...
# Subtest: single disk layout accepts one root disk and split requires roles distintos
ok 76 - single disk layout accepts one root disk and split requires roles distintos
  ---
  duration_ms: 22.915662
  type: 'test'
  ...
# Subtest: split summary reports explicit system and data disks
ok 77 - split summary reports explicit system and data disks
  ---
  duration_ms: 0.742538
  type: 'test'
  ...
# Subtest: storage recommendation prefers safe redundant profiles
ok 78 - storage recommendation prefers safe redundant profiles
  ---
  duration_ms: 3.232708
  type: 'test'
  ...
# Subtest: installExecution
    # Subtest: createInitialExecutionState
        # Subtest: creates idle state
        ok 1 - creates idle state
          ---
          duration_ms: 1.522392
          type: 'test'
          ...
        1..1
    ok 1 - createInitialExecutionState
      ---
      duration_ms: 4.138783
      type: 'suite'
      ...
    # Subtest: hydrateExecutionState
        # Subtest: hydrates running state correctly
        ok 1 - hydrates running state correctly
          ---
          duration_ms: 0.694776
          type: 'test'
          ...
        # Subtest: hydrates completed state
        ok 2 - hydrates completed state
          ---
          duration_ms: 0.316438
          type: 'test'
          ...
        # Subtest: hydrates failed state
        ok 3 - hydrates failed state
          ---
          duration_ms: 0.297761
          type: 'test'
          ...
        1..3
    ok 2 - hydrateExecutionState
      ---
      duration_ms: 2.023679
      type: 'suite'
      ...
    # Subtest: applyExecutionStatus
        # Subtest: transitions state correctly
        ok 1 - transitions state correctly
          ---
          duration_ms: 1.558808
          type: 'test'
          ...
        1..1
    ok 3 - applyExecutionStatus
      ---
      duration_ms: 1.83996
      type: 'suite'
      ...
    # Subtest: buildInstallStageList
        # Subtest: marks completed phases as done and current as active
        ok 1 - marks completed phases as done and current as active
          ---
          duration_ms: 1.13187
          type: 'test'
          ...
        # Subtest: marks all as done if completed
        ok 2 - marks all as done if completed
          ---
          duration_ms: 0.391955
          type: 'test'
          ...
        # Subtest: marks current phase as failed if failed
        ok 3 - marks current phase as failed if failed
          ---
          duration_ms: 0.341267
          type: 'test'
          ...
        1..3
    ok 4 - buildInstallStageList
      ---
      duration_ms: 2.594395
      type: 'suite'
      ...
    1..4
ok 79 - installExecution
  ---
  duration_ms: 12.687905
  type: 'suite'
  ...
# Subtest: installPlan
    # Subtest: isStrongPassword
        # Subtest: requires at least 12 characters
        ok 1 - requires at least 12 characters
          ---
          duration_ms: 1.277892
          type: 'test'
          ...
        # Subtest: requires at least 3 character classes
        ok 2 - requires at least 3 character classes
          ---
          duration_ms: 0.445453
          type: 'test'
          ...
        1..2
    ok 1 - isStrongPassword
      ---
      duration_ms: 2.931613
      type: 'suite'
      ...
    # Subtest: buildInstallPlanPayload
        # Subtest: builds a default valid payload
        ok 1 - builds a default valid payload
          ---
          duration_ms: 1.534255
          type: 'test'
          ...
        # Subtest: activates srvData appropriately
        ok 2 - activates srvData appropriately
          ---
          duration_ms: 0.383036
          type: 'test'
          ...
        1..2
    ok 2 - buildInstallPlanPayload
      ---
      duration_ms: 2.183215
      type: 'suite'
      ...
    # Subtest: validateStep
        # Subtest: validates eula step
        ok 1 - validates eula step
          ---
          duration_ms: 1.358599
          type: 'test'
          ...
        # Subtest: validates network step
        ok 2 - validates network step
          ---
          duration_ms: 0.901949
          type: 'test'
          ...
        # Subtest: validates users step with weak password
        ok 3 - validates users step with weak password
          ---
          duration_ms: 1.220993
          type: 'test'
          ...
        # Subtest: allows weak password <REDACTED> allowWeakPassword <REDACTED> true
        ok 4 - allows weak password <REDACTED> allowWeakPassword <REDACTED> true
          ---
          duration_ms: 1.525387
          type: 'test'
          ...
        1..4
    ok 3 - validateStep
      ---
      duration_ms: 5.676811
      type: 'suite'
      ...
    1..3
ok 80 - installPlan
  ---
  duration_ms: 11.642091
  type: 'suite'
  ...
# Subtest: storagePlanner
    # Subtest: validateSingleDiskLayout
        # Subtest: requires a selected disk
        ok 1 - requires a selected disk
          ---
          duration_ms: 1.900274
          type: 'test'
          ...
        # Subtest: validates eligible disk
        ok 2 - validates eligible disk
          ---
          duration_ms: 1.001469
          type: 'test'
          ...
        # Subtest: rejects ineligible disk
        ok 3 - rejects ineligible disk
          ---
          duration_ms: 0.682661
          type: 'test'
          ...
        1..3
    ok 1 - validateSingleDiskLayout
      ---
      duration_ms: 5.212836
      type: 'suite'
      ...
    # Subtest: validateSplitDiskLayout
        # Subtest: requires both disks to be different
        ok 1 - requires both disks to be different
          ---
          duration_ms: 0.969122
          type: 'test'
          ...
        # Subtest: validates two distinct eligible disks
        ok 2 - validates two distinct eligible disks
          ---
          duration_ms: 0.775386
          type: 'test'
          ...
        1..2
    ok 2 - validateSplitDiskLayout
      ---
      duration_ms: 2.232818
      type: 'suite'
      ...
    # Subtest: validateRaidSelection
        # Subtest: validates RAID 1 with 2 homogeneous disks
        ok 1 - validates RAID 1 with 2 homogeneous disks
          ---
          duration_ms: 1.656589
          type: 'test'
          ...
        # Subtest: rejects RAID 1 with heterogeneous disks if deviation > 5%
        ok 2 - rejects RAID 1 with heterogeneous disks if deviation > 5%
          ---
          duration_ms: 0.954171
          type: 'test'
          ...
        # Subtest: validates RAID 0 with heterogeneous disks but warns about waste
        ok 3 - validates RAID 0 with heterogeneous disks but warns about waste
          ---
          duration_ms: 1.884477
          type: 'test'
          ...
        # Subtest: rejects RAID 5 with < 3 disks
        ok 4 - rejects RAID 5 with < 3 disks
          ---
          duration_ms: 0.56375
          type: 'test'
          ...
        # Subtest: rejects RAID 10 with odd number of disks (5 disks)
        ok 5 - rejects RAID 10 with odd number of disks (5 disks)
          ---
          duration_ms: 0.827246
          type: 'test'
          ...
        1..5
    ok 3 - validateRaidSelection
      ---
      duration_ms: 7.066766
      type: 'suite'
      ...
    1..3
ok 81 - storagePlanner
  ---
  duration_ms: 15.865788
  type: 'suite'
  ...
# Subtest: fuzz: splitWizardPatch nunca vaza chaves desconhecidas nem polui o prototype
ok 82 - fuzz: splitWizardPatch nunca vaza chaves desconhecidas nem polui o prototype
  ---
  duration_ms: 21.169897
  type: 'test'
  ...
# Subtest: fuzz: input hostil de localStorage (JSON com __proto__) não polui Object.prototype
ok 83 - fuzz: input hostil de localStorage (JSON com __proto__) não polui Object.prototype
  ---
  duration_ms: 0.363634
  type: 'test'
  ...
# Subtest: fuzz: validateStep(network) trata httpPort exatamente como o payload define
ok 84 - fuzz: validateStep(network) trata httpPort exatamente como o payload define
  ---
  duration_ms: 93.564995
  type: 'test'
  ...
# Subtest: fuzz: validateStep(network) modo estático rejeita IP/gateway malformados
ok 85 - fuzz: validateStep(network) modo estático rejeita IP/gateway malformados
  ---
  duration_ms: 79.414533
  type: 'test'
  ...
# Subtest: fuzz: validateStep nunca lança para drafts arbitrários em qualquer step
ok 86 - fuzz: validateStep nunca lança para drafts arbitrários em qualquer step
  ---
  duration_ms: 217.34773
  type: 'test'
  ...
# Subtest: fuzz: mergeWizardState é estável sob re-split repetido
ok 87 - fuzz: mergeWizardState é estável sob re-split repetido
  ---
  duration_ms: 71.351274
  type: 'test'
  ...
# Subtest: draft e uiState nao vazam campos um para o outro
ok 88 - draft e uiState nao vazam campos um para o outro
  ---
  duration_ms: 3.65683
  type: 'test'
  ...
# Subtest: mergeWizardState preserva selectedDisks do draft
ok 89 - mergeWizardState preserva selectedDisks do draft
  ---
  duration_ms: 0.630135
  type: 'test'
  ...
1..89
# tests 112
# suites 13
# pass 111
# fail 1
# cancelled 0
# skipped 0
# todo 0
# duration_ms 958.693766
```
- installer node test: FAIL rc=1


Final status: FAIL
