from openpyxl.styles import Border, Side, PatternFill, Font, GradientFill, Alignment

def autofit(worksheet):
    for col in worksheet.columns:
        max_length = 0
        column = col[0].column # Get the column name
        for cell in col:
            try: # Necessary to avoid error on empty cells
                if len(str(cell.value)) > max_length:
                    max_length = len(cell.value)
            except:
                pass
        adjusted_width = (max_length + 2)
        worksheet.column_dimensions[column].width = adjusted_width

def hide_grid_lines(sheet):
    sheet.sheet_view.showGridLines = False