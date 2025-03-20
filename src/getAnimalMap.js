const data = require('../data/zoo_data');

function getAnimalBySex(sex, current) {
  return current.residents.reduce((acc, curr) => {
    if (!sex) acc.push(curr.name);
    if (curr.sex === sex) acc.push(curr.name);
    return acc;
  }, []);
}

function getAnimalsList({ includeNames, sex, sorted }) {
  return data.species.reduce((acc, curr) => {
    acc[curr.location].push(includeNames ? {
      [curr.name] : sorted ? getAnimalBySex(sex, curr).sort() : getAnimalBySex(sex, curr)
    } : curr.name);
    return acc;
  }, {
    NE: [],
    NW: [],
    SE: [],
    SW: [],
  });
}

function getAnimalMap(options = { includeNames: false, sex: undefined, sorted: false }) {
  return getAnimalsList(options);
}

module.exports = getAnimalMap;
