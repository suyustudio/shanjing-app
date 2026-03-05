.class final Ll1/b;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ls0/d;


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Ls0/d<",
        "Ljava/lang/Object;",
        ">;"
    }
.end annotation


# static fields
.field public static final d:Ll1/b;

.field private static final e:Ls0/g;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Ll1/b;

    invoke-direct {v0}, Ll1/b;-><init>()V

    sput-object v0, Ll1/b;->d:Ll1/b;

    sget-object v0, Ls0/h;->d:Ls0/h;

    sput-object v0, Ll1/b;->e:Ls0/g;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public getContext()Ls0/g;
    .locals 1

    sget-object v0, Ll1/b;->e:Ls0/g;

    return-object v0
.end method

.method public resumeWith(Ljava/lang/Object;)V
    .locals 0

    return-void
.end method
