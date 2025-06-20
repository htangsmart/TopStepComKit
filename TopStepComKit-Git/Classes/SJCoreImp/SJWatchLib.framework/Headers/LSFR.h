#pragma once
#include <stdint.h>
#ifdef __cplusplus
namespace SmartLinkCore
{
	class CLFSR
	{
	public:
		CLFSR(){};
		~CLFSR(){};
	public:
		void Encrypt_Data(uint16_t init_key, uint8_t *l_data, uint32_t length);
		uint8_t crc8_maxim(uint8_t *buff, uint16_t length);
		uint16_t get_crc(uint16_t val, uint8_t *buf, uint32_t len);
	private:
		uint16_t Loop_Key(uint16_t key);
		uint16_t Encrypt_OneByte(uint8_t* l_data, uint16_t key);
	};
};
#endif
