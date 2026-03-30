// Ethnicity — 51 codes from DHIS2 option set "52 Ethnicities" (EOcQNbKLlmO)
// Codes are in Lao script, displays in English.

CodeSystem: CHREthnicityCS
Id: chr-ethnicity
Title: "CHR Ethnicity"
Description: "Ethnic groups recognised by the Lao PDR Community Health Record, sourced from the DHIS2 '52 Ethnicities' option set."
* ^url = "http://moh.gov.la/fhir/CodeSystem/chr-ethnicity"
* ^status = #active
* ^caseSensitive = true
* ^content = #complete
* #ລາວ "Lao"
* #ກຶມມຸ "Khmou"
* #ມົ້ງ "Hmong"
* #ຜູ້ໄທ "Phouthai"
* #ໄຕ "Tai"
* #ມະກອງ "Makong"
* #ກະຕ່າງ "Ka-tang"
* #ລື້ "Lue"
* #ອາຄາ "Akha"
* #ຍວນ "Nyouan"
* #ຢັ້ງ "Nyung"
* #ແຊກ "Xek"
* #ໄທເໜືອ "Thai-nua"
* #ໄປຣ "Prai"
* #ຊິງມູນ "Xingmoun"
* #ຜ້ອງ "Phong"
* #ແທ່ນ "Then"
* #ເອີດູ "Oeu-dou"
* #ບິດ "Bid"
* #ລະເມດ "Lamed"
* #ສາມຕ່າວ "Samtao"
* #ຕຣີ "Tri"
* #ຢຣຸ "Nyrou"
* #ຕຣຽງ "Triang"
* #ຕະໂອ້ຍ "Ta-oy"
* #ແຢະ "Nyeh"
* #ເບຣົາ "Brao"
* #ກະຕູ "Katou"
* #ຮາຮັກ "Harak"
* #ໂອຍ "Oy"
* #ກຣຽງ "Kriang"
* #ເຈັງ "Cheng"
* #ສະດ່າງ "Sadang"
* #ຊ່ວຍ "Xouay"
* #ຍະເຫີນ "Nyaheun"
* #ລະວີ "Lavi"
* #ປະໂກະ "Pako"
* #ຂະແມ່ "Kha-meh"
* #ຕຸ້ມ "Toum"
* #ງວນ "Ngouan"
* #ມ້ອຍ "Moy"
* #ກຣີ "Kri"
* #ອີວມຽນ "Eio-miang"
* #ພູນ້ອຍ "Phou-noy"
* #ລາຫູ "Lahou"
* #ສີລາ "Sila"
* #ຮາຍີ "Hayi"
* #ໂລໂລ "Lolo"
* #ຫໍ້ "Ho"
* #ບຣູ "Brou"
* #ອື່ນໆ "Others"
* #ບໍ່ບອກ "Not applicable"


ValueSet: CHREthnicityVS
Id: chr-ethnicity-vs
Title: "CHR Ethnicity"
Description: "Ethnic groups recognised by the Lao PDR Community Health Record."
* ^url = "http://moh.gov.la/fhir/ValueSet/chr-ethnicity"
* ^status = #active
* include codes from system CHREthnicityCS
