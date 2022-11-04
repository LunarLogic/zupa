export const formatDateToDDMMYY = (dateToFormat: string) => {
  const date = new Date(dateToFormat);
  const day = date.getDate();
  const month = date.getMonth() + 1;
  const year = date.getFullYear().toString().slice(-2);

  return `${day < 10 ? "0" : ""}${day}.${month < 10 ? "0" : ""}${month}.${year}`;
};
