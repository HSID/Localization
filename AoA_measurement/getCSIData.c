/*
 * =====================================================================================
 *       Filename:  getCSIData.c
 *
 *    Description:  This is a C-implemented mex-function for using in matlab to receive
 *                  CSI data from Atheros WNICs
 *   Requirements:  The host need to have an Atheros WNIC;
 *                  The Atheros-CSI-Tools from NTU is also required to be installed.
 *
 *         Author:  Hua Xue
 *         Email :  <xuehuajun@aliyun.com>
 *   Organization:  LION group @ Shanghai Jiao Tong University
 *
 *   Copyright (c)  LION group @ Shanghai Jiao Tong University
 * =====================================================================================
 */

 /*
  * MATLAB usage description
  * function csiData = getCSIData([outputFileName])
  *   INPUTS:
  *     outputFileName -- a string
  *
  *   OUTPUTS:
  *     csiData        -- a matlab struct contains the CSI matrix
  *
  *   Calling the function without giving the outputFileName will turn off logging.
  *   returning an integer value indicates errors.
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <pthread.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "csi_fun.h"

#include "mex.h"

#define BUFSIZE 4096

int quit;
unsigned char buf_addr[BUFSIZE];
unsigned char data_buf[1500];

COMPLEX csi_matrix[3][3][114];
csi_struct*   csi_status;

void sig_handler(int signo)
{
    if (signo == SIGINT)
        quit = 1;
}

void set_err_return_value(mxArray **plhs, int nlhs, int err)
{
    if (nlhs == 1)
    {
        plhs[0] = mxCreateDoubleScalar(err);
    }
}

mxArray *csiMatrix2mxArray(COMPLEX (*csiMatrix)[3][114], int nr, int nc, int num_tones)
{
    int k, nc_idx, nr_idx;
    int size[] = {nr, nc, num_tones};
    mxArray *csi = mxCreateNumericArray(3, size, mxDOUBLE_CLASS, mxCOMPLEX);
    double *ptrR = (double*)mxGetPr(csi);
    double *ptrI = (double*)mxGetPi(csi);

    for (k = 0; k < num_tones; k++)
    {
        for (nc_idx = 0; nc_idx < nc; nc_idx++)
        {
            for (nr_idx = 0; nr_idx < nr; nr_idx++)
            {
                *ptrI = (double)csiMatrix[nr_idx][nc_idx][k].imag;
                ptrI++;
                *ptrR = (double)csiMatrix[nr_idx][nc_idx][k].real;
                ptrR++;
            }
        }
    }
    return csi;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    FILE*       fp = NULL;
    int         fd;
    int         i;
    int         total_msg_cnt,cnt;
    int         log_flag;
    u_int16_t   buf_len;
    char buff[BUFSIZE];
    char *outputFileName;

    log_flag = 1;
    csi_status = (csi_struct*)malloc(sizeof(csi_struct));
    /* check usage */
    if (0 == nrhs){
        log_flag  = 0;
        mexPrintf("/*   log off   */\n");
    }
    if (1 == nrhs){
        mexPrintf("/*   log on    */\n");
        mxGetString(prhs[0], buff, BUFSIZE);
        sprintf(outputFileName, "%s", buff);
        fp = fopen(outputFileName,"a");
        if (!fp){
            mexPrintf("Fail to open <output_file>, are you root?\n");
            fclose(fp);
            set_err_return_value(plhs, nlhs, 1);
            return;
        }
    }
    if (nrhs > 1){
        mexPrintf(" Too many input arguments !\n");
        set_err_return_value(plhs, nlhs, 1);
        return;
    }

    fd = open_csi_device();
    if (fd < 0){
        perror("Failed to open the device...");
        set_err_return_value(plhs, nlhs, errno);
        return;
    }

    mexPrintf("#Receiving data! Press Ctrl+C to quit!\n");

    quit = 0;
    total_msg_cnt = 0;

    while(1){
        if (1 == quit)
            break;

        /* keep listening to the kernel and waiting for the csi report */
        cnt = read_csi_buf(buf_addr,fd,BUFSIZE);

        if (cnt){
            total_msg_cnt += 1;

            /* fill the status struct with information about the rx packet */
            record_status(buf_addr, cnt, csi_status);

            /*
             * fill the payload buffer with the payload
             * fill the CSI matrix with the extracted CSI value
             */
            record_csi_payload(buf_addr, csi_status, data_buf, csi_matrix);

            /* Till now, we store the packet status in the struct csi_status
             * store the packet payload in the data buffer
             * store the csi matrix in the csi buffer
             * with all those data, we can build our own processing function!
             */
            /*porcess_csi(data_buf, csi_status, csi_matrix);*/

            /*Return the csi_matrix combined with csi_status properly.*/
            int k, nc_idx, nr_idx;
            int nr = csi_status->nr;
            int nc = csi_status->nc;
            int num_tones = csi_status->num_tones;

            mxArray *csi = csiMatrix2mxArray(csi_matrix, nr, nc, num_tones);

            const char *fieldNames[] = {"channel", "chanBW", "rate",
                                        "nr", "nc", "num_tones",
                                        "rssi", "rssi_0", "rssi_1",
                                        "rssi_2", "payload_len", "csi_matrix"};
#define NUMBER_OF_FIELDS (sizeof(fieldNames)/sizeof(*fieldNames))
            plhs[0] = mxCreateStructMatrix(1, 1, NUMBER_OF_FIELDS, fieldNames);

            int fieldNumbers[NUMBER_OF_FIELDS];
            for (k = 0; k < NUMBER_OF_FIELDS; k++)
                fieldNumbers[k] = mxGetFieldNumber(plhs[0], fieldNames[k]);
            mxSetFieldByNumber(plhs[0], 0, fieldNumbers[0], mxCreateDoubleScalar((double)csi_status->channel));
            mxSetFieldByNumber(plhs[0], 0, fieldNumbers[1], mxCreateDoubleScalar((double)csi_status->chanBW));
            mxSetFieldByNumber(plhs[0], 0, fieldNumbers[2], mxCreateDoubleScalar((double)csi_status->rate));
            mxSetFieldByNumber(plhs[0], 0, fieldNumbers[3], mxCreateDoubleScalar((double)csi_status->nr));
            mxSetFieldByNumber(plhs[0], 0, fieldNumbers[4], mxCreateDoubleScalar((double)csi_status->nc));
            mxSetFieldByNumber(plhs[0], 0, fieldNumbers[5], mxCreateDoubleScalar((double)csi_status->num_tones));
            mxSetFieldByNumber(plhs[0], 0, fieldNumbers[6], mxCreateDoubleScalar((double)csi_status->rssi));
            mxSetFieldByNumber(plhs[0], 0, fieldNumbers[7], mxCreateDoubleScalar((double)csi_status->rssi_0));
            mxSetFieldByNumber(plhs[0], 0, fieldNumbers[8], mxCreateDoubleScalar((double)csi_status->rssi_1));
            mxSetFieldByNumber(plhs[0], 0, fieldNumbers[9], mxCreateDoubleScalar((double)csi_status->rssi_2));
            mxSetFieldByNumber(plhs[0], 0, fieldNumbers[10], mxCreateDoubleScalar((double)csi_status->payload_len));
            mxSetFieldByNumber(plhs[0], 0, fieldNumbers[11], csi);

            mexPrintf("Recv %dth msg with rate: 0x%02x | payload len: %d\n",total_msg_cnt,csi_status->rate,csi_status->payload_len);

            /* log the received data for off-line processing */
            if (log_flag){
                buf_len = csi_status->buf_len;
                fwrite(&buf_len,1,2,fp);
                fwrite(buf_addr,1,buf_len,fp);
            }
            else break;
        }
    }
    if (fp)
        fclose(fp);
    close_csi_device(fd);
    free(csi_status);
    return;
}
