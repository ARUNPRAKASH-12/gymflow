import ExcelJS from 'exceljs';

export async function exportToExcel(data, options = {}) {
  const {
    sheetName = 'Report',
    columns = [],
    filename = 'report.xlsx',
  } = options;

  const workbook = new ExcelJS.Workbook();
  workbook.creator = 'GymFlow';
  workbook.created = new Date();

  const sheet = workbook.addWorksheet(sheetName, {
    views: [{ state: 'frozen', ySplit: 1 }],
  });

  // Define columns
  sheet.columns = columns.map((col) => ({
    header: col.header,
    key: col.key,
    width: col.width || 20,
    style: col.style || {},
  }));

  // Style header row
  const headerRow = sheet.getRow(1);
  headerRow.font = { bold: true, color: { argb: 'FFFFFFFF' }, size: 12 };
  headerRow.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF1A1A2E' } };
  headerRow.alignment = { horizontal: 'center', vertical: 'middle' };
  headerRow.height = 30;

  // Add data
  if (data && data.length > 0) {
    sheet.addRows(data);

    // Style data rows
    sheet.eachRow((row, rowNumber) => {
      if (rowNumber > 1) {
        row.alignment = { vertical: 'middle' };
        row.height = 24;
        row.eachCell((cell) => {
          cell.border = {
            top: { style: 'thin', color: { argb: 'FFE2E8F0' } },
            bottom: { style: 'thin', color: { argb: 'FFE2E8F0' } },
          };
        });
        // Alternating row colors
        if (rowNumber % 2 === 0) {
          row.eachCell((cell) => {
            cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFF8FAFC' } };
          });
        }
      }
    });
  }

  const buffer = await workbook.xlsx.writeBuffer();
  return buffer;
}

export function getExcelColumns(type) {
  switch (type) {
    case 'members':
      return [
        { header: 'Name', key: 'name', width: 25 },
        { header: 'Email', key: 'email', width: 30 },
        { header: 'Phone', key: 'phone', width: 18 },
        { header: 'Plan', key: 'plan', width: 20 },
        { header: 'Status', key: 'status', width: 12 },
        { header: 'Start Date', key: 'start_date', width: 15 },
        { header: 'End Date', key: 'end_date', width: 15 },
        { header: 'Trainer', key: 'trainer', width: 20 },
      ];
    case 'payments':
      return [
        { header: 'Invoice No', key: 'invoice', width: 20 },
        { header: 'Member', key: 'member', width: 25 },
        { header: 'Amount', key: 'amount', width: 15 },
        { header: 'Method', key: 'method', width: 15 },
        { header: 'Plan', key: 'plan', width: 20 },
        { header: 'Date', key: 'date', width: 15 },
        { header: 'Status', key: 'status', width: 12 },
      ];
    case 'attendance':
      return [
        { header: 'Date', key: 'date', width: 15 },
        { header: 'Member', key: 'member', width: 25 },
        { header: 'Check In', key: 'check_in', width: 12 },
        { header: 'Check Out', key: 'check_out', width: 12 },
        { header: 'Method', key: 'method', width: 12 },
        { header: 'Duration', key: 'duration', width: 10 },
      ];
    default:
      return [
        { header: 'ID', key: 'id', width: 36 },
        { header: 'Name', key: 'name', width: 25 },
        { header: 'Value', key: 'value', width: 20 },
      ];
  }
}

export function mapDataForExport(type, records) {
  if (!records || records.length === 0) return [];

  switch (type) {
    case 'members':
      return records.map((r) => ({
        name: r.profile?.full_name || r.name || 'Unknown',
        email: r.user?.email || r.email || '',
        phone: r.user?.phone || r.phone || '',
        plan: r.plan?.name || r.membership_plan || '',
        status: r.status || '',
        start_date: r.start_date || '',
        end_date: r.end_date || '',
        trainer: r.trainer?.name || r.trainer_name || '',
      }));

    case 'payments':
      return records.map((r) => ({
        invoice: r.invoice_number || r.id?.substring(0, 8),
        member: r.profile?.full_name || r.member_name || 'Member',
        amount: r.amount || 0,
        method: r.method || '',
        plan: r.plan?.name || '',
        date: r.payment_date?.substring(0, 10) || '',
        status: r.status || '',
      }));

    case 'attendance':
      return records.map((r) => ({
        date: r.date || '',
        member: r.profile?.full_name || 'Unknown',
        check_in: r.check_in?.substring(11, 19) || '',
        check_out: r.check_out?.substring(11, 19) || '',
        method: r.method || '',
        duration: r.duration || '',
      }));

    default:
      return records;
  }
}
