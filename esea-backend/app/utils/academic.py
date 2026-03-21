from datetime import date

def compute_year(join_year: int | None):
    if not join_year:
        return None

    today = date.today()
    academic_year = today.year

    if today.month < 7:
        academic_year -= 1

    year_number = academic_year - join_year + 1

    mapping = {
        1: "1st Year",
        2: "2nd Year",
        3: "3rd Year",
        4: "4th Year",
        5: "5th Year",
    }

    return mapping.get(year_number, f"{year_number}th Year")
