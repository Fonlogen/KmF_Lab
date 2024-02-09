Config = {}

Config.Debug = false

Config.DatabaseSaveTime = 12 * 60000 -- Minutes

Config.LabPrice = 100000;
Config.LabTaxPrice = 50000;

Config.LabPositions = {
  ['pubblico_1'] = {
    position = vector3(929.48, -1901.43, 31.29),
    rotation = -5,
    size = vector3(1.1, 2.7, 0.7),
    blip = {
      sprite = 499,
      color = 50,
      scale = 0.7,
      label = 'Laboratorio Pubblico',
    },
  },
  ['pubblico_2'] = {
    position = vector3(164.51, -250.57, 51.43),
    rotation = -20,
    size = vector3(0.5, 0.5, 0.5),
    blip = {
      sprite = 499,
      color = 50,
      scale = 0.7,
      label = 'Laboratorio Pubblico',
    },
  },
  ['bunker'] = {
    position = vector3(908.93, -3207.99, -97.23),
    rotation = 25,
    size = vector3(0.5, 0.5, 0.5),
  }
}

Config.FakeLabPositions = {
  vector3(162.57, -252.26, 50.40),
  vector3(929.49, -1895.07, 30.18)
}

Config.FakeLabItems = {
  'box_beackers',
  'box_testtubes',
  'box_books'
}

Config.LabList = {
  ['lab_meth'] = {
    img = 'https://i.imgur.com/jWj7RlO.png',
    title = 'Laboratorio Metanfetamina',
    description = 'Un laboratorio per la lavorazione della metanfetamina',
    price = 10000,
    tax = (10000 / 100) * 2,
  },
  ['lab_cocaina'] = {
    img = 'https://i.imgur.com/nrmmHbc.png',
    title = 'Laboratorio Cocaina',
    description = 'Un laboratorio per la lavorazione della cocaina',
    price = 10000,
    tax = (10000 / 100) * 3,
  },
  ['lab_codeina'] = {
    img = 'https://i.imgur.com/W924B8j.png',
    title = 'Laboratorio Codeina',
    description = 'Un laboratorio per la lavorazione della codeina',
    price = 10000,
    tax = (10000 / 100) * 1,
  },
}

Config.UpgradesList = {
  ['deposit_upgrade'] = {
    title = 'Aggiornamento capacità di deposito',
    description = 'Aumenta la capacità di deposito di 10 slot',
    price = 8500,
    max_level = 20,
    level = 0,
    price_multiplier = 1.2,
    disabled = false,
  },
  ['crafting_time_upgrade'] = {
    title = 'Aggiornamento tempo di lavorazione',
    description = 'Riduce il tempo di lavorazione del 5%',
    price = 35000,
    price_multiplier = 1.2,
    level = 0,
    max_level = 10,
    disabled = false,
  },
  ['crafting_table_upgrade'] = {
    title = 'Nuova postazione di crafting',
    description = 'Sblocca una nuova postazione di crafting',
    price = 50000,
    max_level = 100,
    level = 1,
    price_multiplier = 1.15,
    disabled = false,
  },
  ['crafting_fortune_upgrade'] = {
    title = 'Fortuna di lavorazione',
    description = 'Aumenta la fortuna del 1% per ogni livello, aumentando la possibilità di ottenere 1 prodotto aggiuntivo dopo il crafting',
    price = 30000,
    max_level = 30,
    level = 0,
    price_multiplier = 1.08,
    disabled = false,
  },
  ['max_employees_upgrade'] = {
    title = 'Aggiornamento dipendenti massimi',
    description = 'Aumenta il numero massimo di dipendenti di 1',
    price = 35000,
    max_level = 40,
    level = 0,
    price_multiplier = 1.008,
    disabled = false,
  },
  ['max_attackers_upgrade'] = {
    title = 'Aggiornamento attaccanti massimi',
    description = 'Aumenta il numero massimo di attaccanti di 10',
    price = 12000,
    max_level = 100,
    level = 0,
    price_multiplier = 1.001,
    disabled = true,
  },
  ['max_defenders_upgrade'] = {
    title = 'Aggiornamento difensori massimi',
    description = 'Aumenta il numero massimo di difensori di 10',
    price = 12000,
    max_level = 100,
    level = 0,
    price_multiplier = 1.001,
    disabled = true,
  },

  -- ATTACCHI
  ['attack_spy_upgrade'] = {
    title = 'Aggiornamento spia offensiva',
    description = 'Permette di aumentare le informazioni rinvenute durante un offensiva',
    price = 130000,
    max_level = 5,
    level = 0,
    price_multiplier = 1.4,
    disabled = true,
  },
  ['attack_spy_price_upgrade'] = {
    title = 'Aggiornamento costo spia offensiva',
    description = 'Riduce il costo di una spia offensiva del 5%',
    price = 100000,
    max_level = 15,
    level = 0,
    price_multiplier = 1.6,
    disabled = true,
  },
  ['attack_spy_time_upgrade'] = {
    title = 'Aggiornamento tempo spia offensiva',
    description = 'Riduce il tempo necessario per spiare un laboratorio del 5%',
    price = 80000,
    max_level = 5,
    level = 0,
    price_multiplier = 1.6,
    disabled = true,
  },
  ['attack_time_upgrade'] = {
    title = 'Aggiornamento tempo di attacco',
    description = 'Riduce il tempo necessario per attaccare del 5%',
    price = 100000,
    max_level = 10,
    level = 0,
    price_multiplier = 1.8,
    disabled = true,
  },
  ['attack_upgrade'] = {
    title = 'Aggionamento risorse di attacco',
    description = 'Aumenta le risorse rinvenute durante un attacco del 5%',
    price = 130000,
    max_level = 20,
    level = 0,
    price_multiplier = 1.2,
    disabled = true,
  },
  ['defence_upgrade'] = {
    title = 'Aggionamento risorse di difesa',
    description = 'Diminuisce le risorse richieste per riparare danni subiti durante un attacco del 5%',
    price = 130000,
    max_level = 10,
    level = 0,
    price_multiplier = 1.2,
    disabled = true,
  },
  ['defence_spy'] = {
    title = 'Aggiornamento spia difensiva',
    description = 'Permette di aumentare le informazioni dell\'attaccante rinvenute dopo un attacco',
    price = 130000,
    max_level = 5,
    level = 0,
    price_multiplier = 1.4,
    disabled = true,
  },
  ['counter_attack'] = {
    title = 'Aggiornamento contrattacco',
    description = 'Permette di contrattaccare immediatamente il laboratorio attaccante',
    price = 1500000,
    max_level = 1,
    level = 0,
    price_multiplier = 1.4,
    disabled = true,
  },
}

Config.WhitelistedDepositItems = {
  { name = "panettacocalq", label = "Panetta di Cocaina LQ"},
  { name = "panettacocamq", label = "Panetta di Cocaina MQ"},
  { name = "panettacocahq", label = "Panetta di Cocaina HQ"},
  { name = "panettamethlq", label = "Panetta di Meth LQ"},
  { name = "panettamethmq", label = "Panetta di Meth MQ"},
  { name = "panettamethhq", label = "Panetta di Meth HQ"},
  { name = "panettacodeinalq", label = "Panetta di Codeina LQ"},
  { name = "panettacodeinamq", label = "Panetta di Codeina MQ"},
  { name = "panettacodeinahq", label = "Panetta di Codeina HQ"},
  { name = "solventeapolare2", label = "Solvente Apolare", chooseDeposit=true, chooseWithdraw=true},
  { name = "cassettadicocaina", label = "Cassetta di Cocaina"},
  { name = "cassettadicodeina", label = "Cassetta di Codeina"},
  { name = "cassettadimeth", label = "Cassetta di Meth"},
  { name = "solvaflora", label = "SolvaFlora", chooseDeposit=false, chooseWithdraw=false },
  { name = "fialettasolvaflora", label = "Fialetta di SolvaFlora", chooseDeposit=true, chooseWithdraw=true },
  { name = "weed", label = 'Marijuana', chooseDeposit=true, chooseWithdraw=true}
}

Config.CraftingList = {
  ['fialettasolvaflora'] = {
    requirements = {
      { name = 'solvaflora', label = 'SolvaFlora', count = 1 },
    },
    result = {
      name = 'fialettasolvaflora', label = 'Fialetta di SolvaFlora', count = 50
    },
    time = 10,
    set = nil
  },
  ['panettacocahq'] = {
    requirements = {
      { name = 'cassettadicocaina', label = "Cassetta di Cocaina", count = 1 },
      { name = 'fialettasolvaflora', label = 'Fialetta di SolvaFlora', count = 50 },
      -- { name = 'weed', label = 'Marijuana', count = 5 },
    },
    result = {
      name = 'panettacocahq', label = 'Panetta di Cocaina HQ', count = 3
    },
    time = 30,
    set = nil
  },
  ['panettamethhq'] = {
    requirements = {
      { name = 'cassettadimeth', label =  "Cassetta di Meth", count = 1 },
      { name = 'fialettasolvaflora', label = 'Fialetta di SolvaFlora', count = 50 },
    },
    result = {
      name = 'panettamethhq', label = 'Panetta di Meth HQ', count = 3
    },
    time = 30,
    set = nil
  },
  ['panettacodeinahq'] = {
    requirements = {
      { name = 'cassettadicodeina', label =  "Cassetta di Codeina", count = 1 },
      { name = 'fialettasolvaflora', label = 'Fialetta di SolvaFlora', count = 50 },
    },
    result = {
      name = 'panettacodeinahq', label = 'Panetta di Codeina HQ', count = 3
    },
    time = 30,
    set = nil
  },
  ['panettacocamq'] = {
    requirements = {
      { name = 'panettacocahq', label = 'Panetta di Cocaina HQ', count = 1 },
      { name = 'fialettasolvaflora', label = 'Fialetta di SolvaFlora', count = 50 },
    },
    result = {
      name = 'panettacocamq', label = 'Panetta di Cocaina MQ', count = 3
    },
    time = 60,
    set = 'lab_cocaina'
  },
  ['panettacocalq'] = {
    requirements = {
      { name = 'panettacocamq', label = 'Panetta di Cocaina MQ', count = 1 },
      { name = 'fialettasolvaflora', label = 'Fialetta di SolvaFlora', count = 50 },
    },
    result = {
      name = 'panettacocalq', label = 'Panetta di Cocaina LQ', count = 3
    },
    time = 90,
    set = 'lab_cocaina'
  },
  ['panettamethmq'] = {
    requirements = {
      { name = 'panettamethhq', label = 'Panetta di Meth HQ', count = 1 },
      { name = 'fialettasolvaflora', label = 'Fialetta di SolvaFlora', count = 50 },
    },
    result = {
      name = 'panettamethmq', label = 'Panetta di Meth MQ', count = 3
    },
    time = 60,
    set = 'lab_meth'
  },
  ['panettamethlq'] = {
    requirements = {
      { name = 'panettamethmq', label = 'Panetta di Meth MQ', count = 1 },
      { name = 'fialettasolvaflora', label = 'Fialetta di SolvaFlora', count = 50 },
    },
    result = {
      name = 'panettamethlq', label = 'Panetta di Meth LQ', count = 3
    },
    time = 90,
    set = 'lab_meth'
  },
  ['panettacodeinamq'] = {
    requirements = {
      { name = 'panettacodeinahq', label = 'Panetta di Codeina HQ', count = 1 },
      { name = 'fialettasolvaflora', label = 'Fialetta di SolvaFlora', count = 50 },
    },
    result = {
      name = 'panettacodeinamq', label = 'Panetta di Codeina MQ', count = 3
    },
    time = 60,
    set = 'lab_codeina'
  },
  ['panettacodeinalq'] = {
    requirements = {
      { name = 'panettacodeinamq', label = 'Panetta di Codeina MQ', count = 1 },
      { name = 'fialettasolvaflora', label = 'Fialetta di SolvaFlora', count = 50 },
    },
    result = {
      name = 'panettacodeinalq', label = 'Panetta di Codeina LQ', count = 3
    },
    time = 90,
    set = 'lab_codeina'
  },
}

Config.LabPolyzone = vector3(896.14, -3170.81, -98.12)

-- Config.BunkerProp = 'gr_prop_gr_bunkeddoor_f'

-- Config.BunkerPositions = {
--   {
--     name = 'Bunker 450',
--     position = vector3(2795.50, -778.85, 7.67),
--     rotation = vector3(10.186, -3.307, 125.568),
--   },
--   {
--     name = 'Bunker PALETO SPIAGGIA',
--     position = vector3(210.90, 7000.93, 2.23),
--     rotation = vector3(0.000, 0.000, -132.804),
--   },
--   {
--     name = 'Bunker porto',
--     position = vector3(1132.820, -2597.900, 17.240),
--     rotation = vector3(0.000, 6.994, -88.014),
--   },
--   {
--     name = 'Bunker faro',
--     position = vector3(3342.920, 5599.174, 20.027),
--     rotation = vector3(-10.174, 1.336, -87.153),
--   }
-- }