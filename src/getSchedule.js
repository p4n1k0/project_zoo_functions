const data = require('../data/zoo_data');

const { species, hours } = data;

const createFullSchedule = () => {
  const fullSchedule = {};
  Object.keys(hours).forEach((elem) => {
    fullSchedule[elem] = {
      officeHour: `Open from ${hours[elem].open}am until ${hours[elem].close}pm`,
      exhibition: species.filter((specie) => specie.availability
        .some((avaiable) => avaiable === elem)).map((specie) => specie.name),
    };
  });
  fullSchedule.Monday = { officeHour: 'CLOSED', exhibition: 'The zoo will be closed!' };
  return fullSchedule;
};

function getSchedule(scheduleTarget) {
  if (Object.keys(hours).some((day) => day === scheduleTarget) === true) return { [scheduleTarget]: createFullSchedule()[scheduleTarget] };
  if (species.map((elem) => elem.name).some((name) => name === scheduleTarget) === true) return species.find((elem) => elem.name === scheduleTarget).availability;
  return createFullSchedule();
}

module.exports = getSchedule;
