from shared.services.database_service import db
from ..models.driver import Driver

class DriverService():
    def get_driver_by_phone(self, phone):
        query = "Select * from driver where SDT = %s"
        cursor = db.cursor(dictionary = True)
        try:
            cursor.execute(query, (phone,))
            if(cursor != None):
                result = cursor.fetchone()
                return result
        except Exception as e:
            print("Error occurred:", e)
            return None  
        finally:
            cursor.close()
    
    def update_driver_info(self, driver):
        cursor = db.cursor()
        try:
            cursor.execute("""
                UPDATE driver SET
                Firstname = %s, Lastname = %s, DOB = %s, Gender = %s, Address = %s, 
                CCCD = %s, Driving_licence_number = %s, Working_experiment = %s
                WHERE Driver_ID = %s
            """, (
                driver.firstname, driver.lastname, driver.dob, 
                driver.gender, driver.address, driver.cccd, 
                driver.driving_license, driver.working_experiment, driver.driver_id
            ))
            db.commit()
            return cursor.rowcount
        except Exception as e:
            db.rollback()
            print(f"Error occurred: {e}")
            return 0
        finally:
            cursor.close()