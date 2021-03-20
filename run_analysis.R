#download and unzip the files

if(!dir.exists("./UCI HAR Dataset")){
        print ('creating diretory for UCI HAR Dataset')
        download.file( url='https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip', destfile = 'temp_file.zip')
        unzip('temp_file.zip')
        unlink('temp_file.zip')
}else{
        print ('UCI HAR Dataset directory already exists')
}

###  STEP 1

#Read in "X" and "y" and "subject_train" files and create "train_merged" dataset

library(dplyr)

X_train<-read.table("UCI HAR Dataset/train/X_train.txt")
y_train<-read.table("UCI HAR Dataset/train/y_train.txt")
names(y_train)<-'label'
subject_train<-read.table("UCI HAR Dataset/train/subject_train.txt")
names(subject_train)<-'subject'
train_merged<-cbind(subject_train, y_train, X_train)
rm(list=c('X_train', 'y_train', 'subject_train'))

#Read in "X" and "y" files and create "test_merged" dataset

X_test<-read.table("UCI HAR Dataset/test/X_test.txt")
y_test<-read.table("UCI HAR Dataset/test/y_test.txt")
names(y_test)<-'label'
subject_test<-read.table("UCI HAR Dataset/test/subject_test.txt")
names(subject_test)<-'subject'
test_merged<-cbind(subject_test, y_test, X_test)
rm(list=c('X_test', 'y_test', 'subject_test'))

#merge 'test' and 'train' datasets

data<-tibble(rbind(train_merged, test_merged))
rm(test_merged, train_merged)

### STEP 3 (please see that I chose to perform STEP 2 after steps 3 and 4, for practical reasons)

#re-label column #1 with activity names

##Read in file with activity labels

activities<-read.table("UCI HAR Dataset/activity_labels.txt")
names(activities)<-c('label', 'activity')

##replace 'label' variable with corresponding activity using sapply, data$label, and activities.

data<-data%>%mutate(label=sapply(label, function(x){activities[x,'activity']}))
rm(activities)

### STEP 4

#Rename variables (V1 to V561)

##read in file with variable names

variable_names<-read.table("UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)

##replace variable names

names(data)[3:length(names(data))]<-variable_names[,2]
rm(variable_names)

### STEP 2 (and final step)

#select only 'mean' and 'std' variables

data<-data%>%select(c('subject', 'label', grep('mean\\()|std\\()', names(data), value = TRUE)))

### STEP 5

#calculate means for every variable with data grouped by subject and activity, create second dataframe, and save file

tidy_data_final<-tibble(aggregate(.~subject+label, FUN=mean, data=data))
write.table(tidy_data_final, file='tidy_data_final.txt')

