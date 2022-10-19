const { species } = require('../data/zoo_data');

function countAnimals(animal) {
  if (!animal) {
    return species.reduce((acc, { name, residents }) => {
      acc[name] = residents.length;
      return acc; // Sem parâmetro retorna as espécies animais e sua quantidade
    }, {});
  }
  const { specie, sex: gender } = animal;
  if (!gender) {
    const amountAnimal = species.find(({ name }) => name === specie);
    return amountAnimal.residents.length; // Como parâmetro um objeto apenas com a chave specie, retorna a quantidade de animais daquela espécie
  }
  const amountAnimal = species.find(({ name }) => (
    name === specie)).residents.filter(({ sex }) => sex === gender);
  return amountAnimal.length; // Como parâmetro um objeto com chave specie e sex, retorna a quantidade de animais daquela espécie, no sexo selecionado
}

module.exports = countAnimals;
