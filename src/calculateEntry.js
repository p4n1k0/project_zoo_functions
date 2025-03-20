const { prices } = require('../data/zoo_data');

function countEntrants(entrants) {
  const child = entrants.filter((entrant) => entrant.age < 18).length;
  const adult = entrants.filter((entrant) => entrant.age >= 18 && entrant.age < 50).length;
  const senior = entrants.filter((entrant) => entrant.age >= 50).length;
  return { child, adult, senior }; // Retorna objeto contendo contagem de visitantes pela sua faixa etária
}

function calculateEntry(entrants) {
  if (!entrants || Object.keys(entrants).length === 0) return 0; // Retorna 0 caso parâmetro esteja vazio ou se caso um objeto vazio for passado como parâmetro
  const resultCountEntrants = countEntrants(entrants);
  const valueChildrens = resultCountEntrants.child * prices.child;
  const valueAdults = resultCountEntrants.adult * prices.adult;
  const valueSeniors = resultCountEntrants.senior * prices.senior;
  return valueChildrens + valueAdults + valueSeniors; // Retorna total de preço cobrado para visitar o zoológico
}

module.exports = { calculateEntry, countEntrants };
