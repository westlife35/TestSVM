/*************************************************************************
	> File Name: main.cpp
	> Author: 
	> Mail: 
	> Created Time: 2015年05月25日 星期一 14时36分42秒
 ************************************************************************/

#include <iostream>
#include "linear.h"
#include "math.h"
#include "mex.h"
#include "mat.h"
#include<vector>
#include<sstream>
using namespace std;

void SVM(vector<model*> &outModel,double &dAccuracy,feature_node** trainFeature,double** trainLabel,int nNumOfTrainData,int nNumOfTrainFeature,int nNumOfTrainLabelClass,feature_node** testFeature,double** testLabel,int nNumOfTestData,double lambda );

int main()
{
    MATFile *pMatTrain=matOpen("/home/qc/test/matlab_dataset/VioWH_training_set2.mat","r");
    const char **dirTrain;
    int nDirTrain;
    MATFile *pMatTest=matOpen("/home/qc/test/matlab_dataset/VioWH_testing_set.mat","r");
    const char **dirTest;
    int nDirTest;
    if(pMatTrain==NULL)
    {
        cout<<"Read Train Mat failed"<<endl;
        return 1;
    }
    if(pMatTest==NULL)
    {
        cout<<"Read Test Mat Failed"<<endl;
        return 1;
    }

    dirTrain = (const char **)matGetDir(pMatTrain, &nDirTrain);
    if (dirTrain== NULL) 
    {
        cout<<"Error reading directory of Train Mat: i"<<endl;
        return(1);
    }
    else
    {
        cout<<"Directory of Train Mat:"<<endl;
        for (int i=0; i < nDirTrain; i++)
        {
            cout<<dirTrain[i]<<" ";
        }
        cout<<endl;
    }
    mxFree(dirTrain);


    dirTest = (const char **)matGetDir(pMatTest, &nDirTest);
    if (dirTest== NULL) 
    {
        cout<<"Error reading directory of Test Mat"<<endl;
        return(1);
    }
    else
    {
        cout<<"Directory of Test Mat:"<<endl;
        for (int i=0; i < nDirTest; i++)
        {
            cout<<dirTest[i]<<" ";
        }
        cout<<endl;
    }
    mxFree(dirTest);
   
    //close and reopen : train read
    if (matClose(pMatTrain) != 0) 
    {
    	cout<<"Error closing Train Mat"<<endl;
    	return(1);
    }
    pMatTrain = matOpen("/home/qc/test/matlab_dataset/VioWH_training_set2.mat", "r");
    if (pMatTrain == NULL) 
    {
    	cout<<"Error reopening Train Mat"<<endl;
    	return(1);
    }
    const char* name;//used when train and test data read
    mxArray* mTrainData = matGetNextVariable(pMatTrain, &name);
    if(mTrainData==NULL)
    {
        cout<<"read train_data failed"<<endl;
        return 1;
    }
    mxArray* mTrainLabel=matGetNextVariable(pMatTrain,&name);
    if(mTrainLabel==NULL)
    {
        cout<<"read train_label failed"<<endl;
        return 1;
    }
    
    int nNumOfTrainData=mxGetM(mTrainData);
    int nNumOfTrainFeature=mxGetN(mTrainData);
    int nNumOfTrainLabelClass=mxGetN(mTrainLabel);
    double* pTrainData=mxGetPr(mTrainData);
    double* pTrainLabel=mxGetPr(mTrainLabel);
    if(pTrainData==NULL || pTrainLabel==NULL)
    {
        cout<<"Get TrainMat ptr failed"<<endl;
    }
    cout<<"train_data -> row(nNumOfTrainData): "<<nNumOfTrainData<<"   col(nNumOfTrainFeature):  "<<nNumOfTrainFeature<<"  nNumOfTrainLabelClass: "<<nNumOfTrainLabelClass<<endl;
    
    feature_node** trainFeature;
    trainFeature = new feature_node* [nNumOfTrainData];
    double** trainLabel=new double*[nNumOfTrainLabelClass];
    int nIndex=0;
    for (int i=0;i<nNumOfTrainData;++i)
    {
        trainFeature[i] = new struct feature_node[nNumOfTrainFeature+1];
        for(int j=0;j<nNumOfTrainFeature;++j)
        {
            if( *(pTrainData+i*(nNumOfTrainFeature+1)+j)!=0 )
            {
                trainFeature[i][nIndex].index=j+1;
                nIndex++;
                //cout<<*( pTrainData+i*(nNumOfTrainFeature+1)+j );
                //cout<<trainFeature[i][j].index<<" ";
                trainFeature[i][nIndex].value=*(pTrainData+i*(nNumOfTrainFeature+1)+j   );
            }
        }
        trainFeature[i][nIndex].index=-1;
        trainFeature[i][nIndex].value=-1;
        nIndex=0;
        //cout<<endl;
    }
    for(int i=0;i<nNumOfTrainLabelClass;++i)
    {
        trainLabel[i]=new double[nNumOfTrainData];
        for(int j=0;j<nNumOfTrainData;++j)
        {
            if(*(pTrainData+i*(nNumOfTrainData)+j)==0   )
            {
                trainLabel[i][j]=-1;
            }
            else
            {
                trainLabel[i][j]=1;
            }

        }
    }
    
    //close and reopen : test read
    if (matClose(pMatTest) != 0) 
    {
    	cout<<"Error closing Test Mat"<<endl;
    	return(1);
    }
    pMatTest = matOpen("/home/qc/test/matlab_dataset/VioWH_testing_set.mat", "r");
    if (pMatTest == NULL) 
    {
    	cout<<"Error reopening Test Mat"<<endl;
    	return(1);
    }
    mxArray* mTestData = matGetNextVariable(pMatTest, &name);
    if(mTestData==NULL)
    {
        cout<<"read test_data failed"<<endl;
        return 1;
    }
    mxArray* mTestLabel=matGetNextVariable(pMatTest,&name);
    if(mTestLabel==NULL)
    {
        cout<<"read test_label failed"<<endl;
        return 1;
    }
    
    int nNumOfTestData=mxGetM(mTestData);
    int nNumOfTestFeature=mxGetN(mTestData);
    int nNumOfTestLabelClass=mxGetN(mTestLabel);
    double* pTestData=mxGetPr(mTestData);
    double* pTestLabel=mxGetPr(mTestLabel);
    if(pTestData==NULL || pTestLabel==NULL)
    {
        cout<<"Get TestMat ptr failed"<<endl;
    }
    cout<<"test_data -> row(nNumOfTestData): "<<nNumOfTestData<<"   col(nNumOfTestFeature):  "<<nNumOfTestFeature<<"  nNumOfTestLabelClass: "<<nNumOfTestLabelClass<<endl;

    feature_node** testFeature;
    testFeature = new feature_node* [nNumOfTestData];
    double** testLabel=new double*[nNumOfTestLabelClass];
    nIndex=0; 
    for (int i=0;i<nNumOfTestData;++i)
    {
        testFeature[i] = new struct feature_node[nNumOfTestFeature+1];
        for(int j=0;j<nNumOfTestFeature;++j)
        {
            if( *(pTestData+i*(nNumOfTestFeature+1)+j)!=0 )
            {
                testFeature[i][nIndex].index=j+1;
                nIndex++;
                //cout<<*( pTestData+i*(nNumOfTestFeature+1)+j );
                //cout<<testFeature[i][j].index<<" ";
                testFeature[i][nIndex].value=*(pTestData+i*(nNumOfTestFeature+1)+j   );
            }
        }
        testFeature[i][nIndex].index=-1;
        testFeature[i][nIndex].value=-1;
        nIndex=0;
        //cout<<endl;
    }
    for(int i=0;i<nNumOfTestLabelClass;++i)
    {
        testLabel[i]=new double[nNumOfTestData];
        for(int j=0;j<nNumOfTestData;++j)
        {
            if(*(pTestData+i*(nNumOfTestData)+j)==0   )
            {
                testLabel[i][j]=-1;
            }
            else
            {
                testLabel[i][j]=1;
            }
        }
    }



    double dMaxAccuracy=0;
    double dBestSvmLamda=0;
    vector<model*> bestSvmModel;
    bestSvmModel.resize(3);
    for(int i=-6;i<=6;i++)
    {
        double dLambda=pow(10,i);
        double dAccuracy;
        vector<model*> outModel;
        outModel.resize(3);
        SVM(outModel,dAccuracy,trainFeature,trainLabel,nNumOfTrainData,nNumOfTrainFeature,nNumOfTrainLabelClass,testFeature,testLabel,nNumOfTestData,dLambda );
        
        if(dAccuracy>dMaxAccuracy)
        {
            dMaxAccuracy=dAccuracy;
            dBestSvmLamda=dLambda;
            bestSvmModel=outModel;
        }
        cout<<"lambda= 10^"<<i<<", dAccuracy="<<dAccuracy<<",dMaxAccuracy: "<<dMaxAccuracy<<endl;
    }

    cout<<"lambda="<<dBestSvmLamda<<" dMaxAccuracy= "<<dMaxAccuracy<<endl;
    //save model

    
    cout<<"finished"<<endl;

    //release all
    for (int i=0;i<nNumOfTrainData;++i)
    {
        delete[] trainFeature[i];
    }
    delete[] trainFeature;
    for(int i=0;i<nNumOfTrainLabelClass;++i)
    {
        delete[] trainLabel[i];
    }
    delete[] trainLabel;

    for (int i=0;i<nNumOfTestData;++i)
    {
        delete[] testFeature[i];
    }
    delete[] testFeature;
    for(int i=0;i<nNumOfTestLabelClass;++i)
    {
        delete[] testLabel[i];
    }
    delete[] testLabel;

    return 1;
}

void SVM(vector<model*> &outModel,double &dAccuracy,feature_node** trainFeature,double** trainLabel,int nNumOfTrainData,int nNumOfTrainFeature,int nNumOfTrainLabelClass,feature_node** testFeature,double** testLabel,int nNumOfTestData,double lambda )
{
    cout<<"one new training"<<endl;
    //have make the 0 int trainLabel and testLabel equals to -1
    double resultProb[3][nNumOfTestData];
    //double result[nNumOfTestData];
    for(int i=0;i<nNumOfTrainLabelClass;i++)
    {
	    problem prob;
    	prob.l=nNumOfTrainData;
    	prob.n=nNumOfTrainFeature;
    	prob.x=trainFeature;
    	prob.bias=-1;
	    prob.y=trainLabel[i];

    	parameter param;
    	param.solver_type=L2R_L2LOSS_SVR;
        //strange
    	param.eps=2.07913e-317;
    	param.C=lambda;
    	//param.nr_weight=
	    //param.p=
        //cout<<"eps-------------:"<<param.eps<<endl;
    	const char* error=check_parameter(&prob,&param);
    	if(error!=NULL)
    	{
        	cout<<"there are some error in the parameter or prolem set,the error is : "<<error<<endl;
        	return;
    	}
        model* test=train(&prob,&param);
    	//outMode[i]= *train(&prob,&param);
        //outModel[i]=NULL;
        outModel[i] = test;
        stringstream ss;
        ss<<i;
        string temp1;
        string temp2;
        ss>>temp1;
        ss.clear();
        ss<<lambda;
        ss>>temp2;
        string strModelName="Model_"+temp2+"_"+temp1;
        if(!save_model(("/home/qc/test/"+strModelName).data(),test) )
        {
            cout<<"save model success:"<<strModelName<<endl;
        }
        else
        {
             cout<<"save model failed:"<<strModelName<<endl;
        }
	
	    for(int j=0;j<nNumOfTestData;j++)
	    {
	    	double tempProb=predict(outModel[i],testFeature[j]);
            resultProb[i][j]=tempProb;
	    }
        
    }
    //calculate the accuracy
    int nRightNum=0;
    for(int j=0;j<nNumOfTestData;j++)
    {
        int nMaxProb=0;
        int nMaxProbLabel=0;
        for(int i=0;i<3;i++)
        {
            if(nMaxProb<resultProb[i][j])
            {
                nMaxProb=resultProb[i][j];
                nMaxProbLabel=i;
            }            
        }
        if(testLabel[nMaxProbLabel][j]==1)
        {
            nRightNum++;
        }        
    }
    dAccuracy=double(nRightNum)/nNumOfTestData;   
    cout<<"nRightNum:"<<nRightNum<<" nNumOfTestData:"<<nNumOfTestData<<endl;
}
