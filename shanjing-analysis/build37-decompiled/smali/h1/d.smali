.class final Lh1/d;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lh1/x1;


# static fields
.field public static final d:Lh1/d;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Lh1/d;

    invoke-direct {v0}, Lh1/d;-><init>()V

    sput-object v0, Lh1/d;->d:Lh1/d;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public toString()Ljava/lang/String;
    .locals 1

    const-string v0, "Active"

    return-object v0
.end method
