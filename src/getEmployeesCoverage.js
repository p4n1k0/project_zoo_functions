// ref: https://github.com/tryber/sd-015-b-project-zoo-functions/pull/83/commits/1f83e1d6a3017663919322a68392826d36ff6699

const { employees, species } = require('../data/zoo_data');

function getEmployee(person) {
  return employees.find((employee) => ( // Caso o objeto de opçoes tiver a propriedade name, ela servira tanto para o nome da pessoa quanto para o segundo nome. E caso objeto de opçoes tiver a propriedade id, retornará somente a pessoa correspondente ao id
    person.name === employee.firstName
    || person.name === employee.lastName
    || person.id === employee.id
  ));
}

function getSpecies(employee) {
  return employee.responsibleFor.map((id) => ( // Retorna espécies que funcionário é responsável
    species.find((specie) => specie.id === id)
  ));
}

function foundEmployees() {
  return employees.map((employee) => { // Retorna lista de cobertura de todos os funcionários
    const speci = getSpecies(employee); // Usa função de achar espécies para retornar dentro no objetao
    return {
      id: employee.id,
      fullName: `${employee.firstName} ${employee.lastName}`,
      species: speci.map((specie) => specie.name),
      locations: speci.map((specie) => specie.location),
    };
  });
}

function getEmployeesCoverage(person) {
  if (!person) return foundEmployees(); // Caso nao receba parametros, irá retornar lista de cobertura de todas as pessoas funcionárias
  const employee = getEmployee(person);
  if (!employee) { // Caso nao haja nenhuma pessoa com o nome ou id especificados, será lançado uma mensagem de erro
    throw new Error('Informações inválidas');
  }
  const speci = getSpecies(employee);
  return { // Retorna a cobertura de pessoas funcionárias com suas devidas propriedades
    id: employee.id,
    fullName: `${employee.firstName} ${employee.lastName}`,
    species: speci.map((specie) => specie.name),
    locations: speci.map((specie) => specie.location),
  };
}

module.exports = getEmployeesCoverage;
