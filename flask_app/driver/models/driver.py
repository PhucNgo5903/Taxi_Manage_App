class Driver:
    def __init__(self, driver_id, firstname, lastname, sdt, wallet, dob, gender, address, cccd, driving_license, working_experiment):
        self.driver_id = driver_id
        self.firstname = firstname
        self.lastname = lastname
        self.sdt = sdt
        self.wallet = wallet
        self.dob = dob
        self.gender = gender
        self.address = address
        self.cccd = cccd
        self.driving_license = driving_license
        self.working_experiment = working_experiment
    @staticmethod
    def from_dict(source):
        # Convert from dictionary to Driver object
        return Driver(
            driver_id=source.get('Driver_ID'),
            firstname=source.get('Firstname'),
            lastname=source.get('Lastname'),
            sdt=source.get('SDT'),
            wallet=source.get('Wallet'),
            dob=source.get('DOB'),
            gender=source.get('Gender'),
            address=source.get('Address'),
            cccd=source.get('CCCD'),
            driving_license=source.get('Driving_licence_number'),
            working_experiment=source.get('Working_experiment')
        )