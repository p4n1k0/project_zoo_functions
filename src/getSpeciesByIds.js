const { species } = require('../data/zoo_data');

function getSpeciesByIds(...ids) {
  if (!ids.length) return [];
  return (species.filter(({ id: idSpecie }) => (ids.some((id) => idSpecie === id))));
}

module.exports = getSpeciesByIds;
