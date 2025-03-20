const { species } = require('../data/zoo_data');

function countAnimals(animal) {
  if (!animal) return species.reduce((acc, { name, residents }) => {
    acc[name] = residents.length;
    return acc; // Sem parâmetro retorna as espécies animais e sua quantidade
  }, {});

  const { specie, sex: gender } = animal;
  const character = species.find(({ name }) => (name === specie));
  if (!gender) return character.residents.length; // Como parâmetro um objeto apenas com a chave specie, retorna a quantidade de animais daquela espécie    
  return character.residents.filter(({ sex }) => sex === gender).length; // Como parâmetro um objeto com chave specie e sex, retorna a quantidade de animais daquela espécie, no sexo selecionado
}

module.exports = countAnimals;
