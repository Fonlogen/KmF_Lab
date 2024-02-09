let dictionary = {
  'DefencePower': 'Soldati difensori',
  'AttackPower': 'Soldati attaccanti',
  'MaxDefencePower': 'Soldati difensori massimi',
  'MaxAttackPower': 'Soldati attaccanti massimi',
  'MaxDeposit': 'Capacita\' deposito',
  'MaxEmployees': 'Numero massimo di dipendenti',
}

function TranslateStr(input) {
  return dictionary[input] || null;
}

export default TranslateStr;