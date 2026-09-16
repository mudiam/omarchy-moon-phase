.pragma library

var synodicDays = 29.53058867
var knownNewMoonUtc = Date.UTC(2000, 0, 6, 18, 14, 0)

function state(date) {
  var days = (date.getTime() - knownNewMoonUtc) / 86400000
  var age = ((days % synodicDays) + synodicDays) % synodicDays
  var fraction = age / synodicDays
  var illumination = (1 - Math.cos(2 * Math.PI * fraction)) / 2
  return {
    age: age,
    fraction: fraction,
    illumination: illumination,
    name: phaseName(fraction)
  }
}

function phaseIndex(fraction) {
  return Math.floor((fraction * 8) + 0.5) % 8
}

function phaseName(fraction) {
  return ["New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous", "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"][phaseIndex(fraction)]
}

function nextPhaseEvent(date, targetFraction, name) {
  var days = (date.getTime() - knownNewMoonUtc) / 86400000
  var cycle = Math.floor(days / synodicDays)
  var eventDays = cycle * synodicDays + targetFraction * synodicDays

  if (eventDays <= days)
    eventDays += synodicDays

  var timestamp = knownNewMoonUtc + eventDays * 86400000
  return {
    date: new Date(timestamp),
    fraction: targetFraction,
    name: name,
    timestamp: timestamp
  }
}

function upcoming(date) {
  var events = [
    nextPhaseEvent(date, 0, "New Moon"),
    nextPhaseEvent(date, 0.5, "Full Moon")
  ]

  events.sort(function (a, b) {
    return a.timestamp - b.timestamp
  })
  return events
}

function formatDate(date) {
  var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  return months[date.getMonth()] + " " + date.getDate() + ", " + date.getFullYear()
}
