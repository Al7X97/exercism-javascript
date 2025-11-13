// @ts-check

/**
 * Create an appointment
 *
 * @param {number} days
 * @param {number} [now] (ms since the epoch, or undefined)
 *
 * @returns {Date} the appointment
 */
export function createAppointment(days, now = undefined) {
  let today = new Date(now === undefined ? Date.now() : now);
  let appointment = new Date(today);
  appointment.setDate(today.getDate() + days);
  return appointment


}

/**
 * Generate the appointment timestamp
 *
 * @param {Date} appointmentDate
 *
 * @returns {string} timestamp
 */
export function getAppointmentTimestamp(appointmentDate) {
return appointmentDate.toISOString()
}

/**
 * Get details of an appointment
 *
 * @param {string} timestamp (ISO 8601)
 *
 * @returns {Record<'year' | 'month' | 'date' | 'hour' | 'minute', number>} the appointment details
 */
export function getAppointmentDetails(timestamp) {
let date = new Date(timestamp)
let details = {}
details.year = date.getFullYear()
details.month = date.getMonth()
details.date = date.getDate()
details.hour = date.getHours()
details.minute = date.getMinutes()
return details
}

/**
 * Update an appointment with given options
 *
 * @param {string} timestamp (ISO 8601)
 * @param {Partial<Record<'year' | 'month' | 'date' | 'hour' | 'minute', number>>} options
 *
 * @returns {Record<'year' | 'month' | 'date' | 'hour' | 'minute', number>} the appointment details
 */
export function updateAppointment(timestamp, options) {
let date = new Date(timestamp)
let details = {}

  if (options.year   !== undefined) date.setFullYear(options.year);
  if (options.month  !== undefined) date.setMonth(options.month);
  if (options.date   !== undefined) date.setDate(options.date);
  if (options.hour   !== undefined) date.setHours(options.hour);
  if (options.minute !== undefined) date.setMinutes(options.minute);

  details.year = date.getFullYear()
  details.month = date.getMonth()
  details.date = date.getDate()
  details.hour = date.getHours()
  details.minute = date.getMinutes()
return details
}

/**
 * Get available time in seconds (rounded) between two appointments
 *
 * @param {string} timestampA (ISO 8601)
 * @param {string} timestampB (ISO 8601)
 *
 * @returns {number} amount of seconds (rounded)
 */
export function timeBetween(timestampA, timestampB) {
const date1 = new Date(timestampA)
const date2 = new Date(timestampB)
return Math.round(Math.abs(date1.getTime() - date2.getTime())/1000)
}

/**
 * Get available times between two appointment
 *
 * @param {string} appointmentTimestamp (ISO 8601)
 * @param {string} currentTimestamp (ISO 8601)
 */
export function isValid(appointmentTimestamp, currentTimestamp) {
const appointment = new Date(appointmentTimestamp)
const currentDate = new Date(currentTimestamp)
return appointment >= currentDate
}
