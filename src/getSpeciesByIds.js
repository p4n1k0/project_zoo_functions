const { species } = require('../data/zoo_data');

function getSpeciesByIds(...ids) {
  if (!ids.length) { // Retorna array vazio caso função receba nenhum parâmetro
    return [];
  }
  return (species.filter(({ id: idSpecie }) => ( // Retorna um array com a espécie referente ao id e caso receba mais de um id como parâmetro, retorna um array com as espécies referentes aos ids.
    ids.some((id) => idSpecie === id)))
  );
}

module.exports = getSpeciesByIds;
