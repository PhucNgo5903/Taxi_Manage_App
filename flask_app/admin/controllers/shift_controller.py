from flask import jsonify, abort
from ..services.shift_services import ShiftService

shift_service = ShiftService()

class ShiftController:
    def get_2_shift_info(self):
        shifts = shift_service.get_shift_by_ID_and_shift_start_time()
        if shifts:
            shift_info = []
            for shift in shifts:
                shift_info.append({
                    'ID': shift["ID"],
                    'shift_start_time': shift["shift_start_time"],
                   
                })
            return jsonify(shift_info), 200
        else:
            abort(404, description="No users found.")

    def get_full_shift_info(self, ID):
        shifts = shift_service.get_shift_by_all(ID)
        if shifts:
            shift_info = []
            for shift in shifts:
                shift_info.append({
                    'ID': shift["ID"],
                    'Driver_id': shift["Driver_id"],
                    'cab_id': shift["cab_id"],
                    'shift_start_time': shift["shift_start_time"],
                    'shift_end_time': shift["shift_end_time"],
                    'login_time': shift["login_time"],
                    'logout_time': shift["logout_time"],
                })
            return jsonify(shift_info), 200
        else:
            abort(404, description="No users found.")